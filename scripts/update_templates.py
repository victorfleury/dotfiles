"""
Update the VP templates for a given show.

How it works :
- Parse arguments from the cli to get the show to update.
- Query shotgun for TankPublishedFile objects
- Creeate data structure to get :
    - Show: [template]
        - Sequence : [template]
            - Shot : template
- Open template using rdo_nuke_template
- Make changes to the template : switch write_shotgun01 to WriteRdo1 with proper Profile.
- Publish to the proper context.
"""

import argparse
from functools import wraps
import os
from pprint import pprint
import rdo_context

from rdo_comp_pipeline import writeRdo
from rdo_comp_pipeline.writeRdo import profiles
import rdo_logging
from rdo_nuke_template.template import load, publish, update
from rdo_nuke_template import setup
import rdo_nuke_utils
from rdo_shotgun_core import connect

_SG = connect(
    'rdo_animreview_core',
    '07aaa5aba93337583fa85cb5687a007969f6a8704aac350dcb0ce86622d15286'
)

LOG = rdo_logging.getLogger(__file__)
EXCLUDED_SHOWS = [
    "hos",
    "bcs6",
    "fnd2",
    "pop",
    "trt",
    "tlm",
    "tar",
    "tare",
]
FROZEN_SHOWS = ["hal1", "uap1", "slm"]

EXCLUDED_SHOWS.extend(FROZEN_SHOWS)
EXCLUDED_SHOWS.
def timeit(func):
    @wraps(func)
    def wrap(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        end = time.time() - start
        LOG.info("[%s] Done in %s secs", func.__name__, str(end))
        return result
    return wrap


@timeit
def custom_setup(ctx):
    rdo_nuke_utils.colorSetup.initColorPipeline(
        ctx.project.name,
        ctx.name,
        initialized=True,
    )

    sgProject = rdo_nuke.setup.initProjectDefaults(ctx.project.name)

    rdo_nuke_template.setup.setFrameRange(ctx, noMessage=True)

    # remove all viewer nodes
    viewerNodes = nuke.allNodes('Viewer')
    for node in viewerNodes:
        nuke.delete(node)


@timeit
def setupWriteRdo(node=None):
    """Setup the writeRdo node properly

    Cause we are not in a proper setup context and whatnot. Some callbacks are
    not applied... Boo freakin hooo

    So I ripped this off of rdo_comp_pipeline.init.py
    Args:
        node (writeRdo) : A writeRdo node.
    """
    node.addKnob(nuke.Tab_Knob('WriteRdo_Tab', 'WriteRdo'))
    widgetKnob = nuke.PyCustom_Knob('RdoWidget', '')
    node.addKnob(widgetKnob)
    node.addKnob(nuke.Text_Knob("Content_divider", "", ""))
    node['_useCustomContext'].setValue(False)

    widgetKnob.setValue("getWriteRdoWidget(nuke.thisNode())")


@timeit
def get_latest_only(workfile_templates):
    """
    """
    filtered_workfile_templates = []
    data = {}

    for wf in workfile_templates:
        step = wf.get('sg_step').get('name')
        wf_id = wf.get('entity').get('id')
        if not step in data:
            data.setdefault(step, {})
        if not wf_id in data[step]:
            data[step].setdefault(wf_id, [])
        data[step][wf_id].append(wf)

    for step, entity in data.iteritems():
        print 'Filtering step', step
        for _entity, wf in entity.iteritems():
            filtered_workfile_templates.append(
                next(iter(sorted(wf, key=lambda x: x['version_number'],reverse=True)))
            )
    return filtered_workfile_templates


@timeit
def update_template(shows, sequences=None, shot=None, dry_run=False, query_only=False, task=None):
    """Update templates.

    Args:
        show (str): A show
        sequences (list[str]): A list of sequences
        shot (str): A shot
        dry_run (bool): Whether we run the tool or not
        query_only (bool): Performs the query only if True
        task (str): A task

    Returns:
        None
    """
    context = rdo_context.fromEnvironment()
    if not shows:
        active_shows = _SG.find(
            'Project',
            [
                ['sg_status', 'is', 'active'],
                ['name', 'not_in', EXCLUDED_SHOWS],
            ],
        )
    else:
        active_shows = _SG.find(
            'Project',
            [['code', 'in', shows]]
        )

    if not task:
        tasks = ['Layout (S)', 'BMM (S)', 'Animation (S)', 'Crowd Sim (S)']
    else:
        task_map = {
            'anim': 'Animation (S)',
            'bmm': 'BMM (S)',
            'crowd': 'Crowd Sim (S)',
            'layout': 'Layout (S)',
        }
        tasks = [task_map.get(task)]
    # Query shotgun
    filters = [
        ['project', 'in', active_shows],  # context.project.toShotgun()],
        ['sg_step.Step.code', 'in', tasks],
        ['sg_status_list', 'is_not', 'omt'],
        ['tank_type.TankType.code', 'is', 'workfileTemplate'],
    ]
    print filters

    fields = [
        'name',
        'sg_step',
        'entity',
        'sg_variant',
        'sg_path',
        'sg_part',
        'version_number',
        'sg_status_list',
        'project',
    ]

    if shot:
        filters.append(
            ['entity.Shot.code', 'is', shot]
        )

    LOG.info('Performing query for workfileTemplates')

    workfile_templates = _SG.find(
        'TankPublishedFile',
        filters,
        fields,
        order=[
            {'field_name': 'entity.Shot.name', 'direction': 'asc'},
            {'field_name': 'version_number', 'direction': 'desc'},
        ]
    )

    LOG.info(
        'Found {} template(s) for context '.format(
            len(workfile_templates),
        ),
    )
    filtered_templates = get_latest_only(workfile_templates)
    if query_only:
        LOG.info('Filtered {} templates'.format(len(filtered_templates)))
        for template in filtered_templates:
            print template
        LOG.info('Exiting here')
        return

    processed = []
    errors = []
    updated = 0
    for i, workfile_template in enumerate(filtered_templates):
        if sequences:
            workfile_seq = workfile_template.get('entity').get('name').split('_')[0]
            if workfile_seq not in sequences:
                LOG.info('Skipping sequence')
                continue
        LOG.info('-'*50)
        LOG.info(
            '#{0}/{3} Entity {1} - Step {2} - {4}'.format(
                i+1,
                workfile_template.get('entity').get('name'),
                workfile_template.get('sg_step').get('name'),
                len(filtered_templates),
                updated,
            ),
        )
        LOG.info('Opening {0}'.format(workfile_template.get('sg_path')))
        # Get step
        step = _SG.find_one(
            'Step',
            [['id', 'is', workfile_template.get('sg_step').get('id')]],
            ['sg_tank_name']
        )
        # Build context and get profile
        ctx = rdo_context.fromProjectAndEntity(
            workfile_template.get('project').get('name'),  # show,
            entity=workfile_template.get('entity').get('name'),
            step=step.get('sg_tank_name')
        )

        os.environ["RDO_CURRENT_SHOW"] = ctx.project.name
        os.environ["RDO_CURRENT_STEP"] = ctx.step.name
        nuke.scriptClear()
        nuke.scriptOpen(workfile_template.get('sg_path'))
        nuke.root().knob("name").setValue("")
        custom_setup(ctx)
        #setup.initProjectSettings()

        LOG.info('Swapping WriteNode with WriteRdo')
        current_write = nuke.toNode('rdo_shotgunWrite_01')
        if not current_write:
            LOG.warning('No default write node in the template.')
            processed.append(workfile_template.get('entity').get('name'))
            continue
        new_write = nuke.createNode('WriteRdo', inpanel=False)
        writeRdo._api.initializeNode(new_write)
        # new_write.knob('RdoWidget').setValue("getWriteRdoWidget(nuke.thisNode())")
        setupWriteRdo(new_write)

        current_write_input = current_write.input(0)
        current_write_position = current_write.xpos(), current_write.ypos()
        new_write.setInput(0, current_write_input)
        new_write.setXYpos(current_write_position[0], current_write_position[1] + 200)
        nuke.delete(current_write)

        # Reset publish name
        new_write['_publishName'].setValue('')

        # Update the writeRdo
        writeRdo._api.updateNode(
            new_write,
            profile=profiles.PrecompQC,
        )
        writeRdo._api.refreshUI(new_write)

        if not dry_run:
            LOG.info('Publishing template')
            try:
                publish.publishTemplate(
                    ctx=ctx,
                    step=ctx.step.name,
                    variant=workfile_template.get('sg_variant'),
                )
            except AttributeError:
                LOG.error('Could not publish template for {}'.format(workfile_template))
                errors.append(workfile_template)

        else:
            path = '/tmp/{show}/{show}_{step}_{shot}_from_v{version}.nk'.format(
                show=workfile_template.get('project').get('name'),
                step=step.get('sg_tank_name'),
                shot=workfile_template.get('entity').get('name'),
                version=workfile_template.get('version_number')
            )
            if not os.path.exists(os.path.dirname(path)):
                os.makedirs(os.path.dirname(path))
            nuke.scriptSaveAs(path, overwrite=True)
        processed.append((workfile_template.get('entity').get('name'),  workfile_template.get('sg_step').get('name')))
        updated += 1

    with open('/mnt/users/vfleury/error_templates.json', 'w') as output_errors:
        import json
        json.dump(errors, output_errors, indent=4)



if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='Update precomp templates')
    parser.add_argument(
        '-s',
        '--shows',
        nargs='+',
        help='A show to update precomp templates on',
    )

    parser.add_argument(
        '--dry_run',
        action='store_true',
    )

    parser.add_argument(
        '--sequences',
        nargs='+',
        help='A list of sequences to search for template'
    )

    parser.add_argument(
        '--shot',
        help='A shot to search for template'
    )

    parser.add_argument(
        '--task',
        help='A task to perform on. Default is all (Layout, Anim, BMM, Crowd).'
    )
    parser.add_argument('--query_only', action='store_true', help='Query only')

    args = parser.parse_args()
    print 'ARGS', args

    update_template(args.shows, args.sequences, args.shot, args.dry_run, args.query_only, args.task)
