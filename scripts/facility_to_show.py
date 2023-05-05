"""Facility to show nuke template publisher."""
import argparse
from functools import wraps
import os
import shutil
import tempfile
import time

import rdo_context
from rdo_comp_pipeline import writeRdo
import rdo_logging
from rdo_nuke_template.template.load import getTemplatePublish, loadTemplate
from rdo_nuke_template.template.update import updateWriteNodesContext
from rdo_nuke_template.nodes import Backdrop
from rdo_nuke_template import setup
from rdo_nuke_template import utils
import rdo_nuke_utils
from rdo_publish_pipeline import manager
import rdo_render_publisher
from rdo_rez_core.process import RezContextProcess
from rdo_shotgun_core import connect
from rdo_nuke_template.template import publish


SHOTGUN_SCRIPT_NAME = 'Nuke'
SHOTGUN_SCRIPT_KEY = '11bf44410cb7bd5cd8403b4861784ed5514f52be'
_SG = connect(
    SHOTGUN_SCRIPT_NAME,
    SHOTGUN_SCRIPT_KEY,
)
LOG = rdo_logging.getLogger(__name__)
PUBLISHED_FILE_KNOB = "rdo_templatePublishedFile"


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
def updateTemplate():
    """Update template content: read, writes, placeholders, chunks.""" fdksjfklsdjflksjdflksdjf

    # Sync data
    # ReadManager().forceSync()

    # update ReadRdo and WriteRdo nodes context
    updateWriteNodesContext()

    # Update placeholder nodes
    for node in utils.getLeafLevelPlaceholders():
        loadKnob = node.knob("rdo_load") or node.knob("load")
        loadKnob.execute()

    for chunk in [n for n in nuke.allNodes() if Backdrop.nodeIsChunk(n)]:
        chunk.knob("rdo_resolveContent").setValue(True)
        chunk.knob("rdo_load").execute()

    # update settings
    setup.initProjectSettings()


@timeit
def fetch_publishes(tasks):
    """Fetch publishes at facility level.

    Args:
        tasks (list): A list of tasks.
    """
    for task in tasks:
        ctx = rdo_context.Facility(step=task)
        LOG.info("Searching for template for task {}".format(task))
        publish = getTemplatePublish(ctx, "main")
        published_file = publish.version(manager.version.latestApprovedOrLatest)
        yield task, published_file.path[0]


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
def publish_template(ctx, variant, path):
    """Publish the template

    This uses logic from `rdo_nuke_template` that did not fit the logic here.

    Args:
        ctx (`rdo_context.Context`): The context we publish to.
        variant (str): The variant we want to use.
        path (str): The source path

    Returns:
        bool: True if it succeeded, False otherwise.
    """
    fileToPublish = manager.prepare(
        path,
        ctx,
        "workfileTemplate",
        step=ctx.step.name,
        variant=variant,
        applicationName="nuke",
    )

    # We are using pending publish to be able to write the published file string
    # into to the file (for later dependency query)
    pendingPublish = rdo_render_publisher.preRenderPublish(
        fileToPublish,
        createPlaceholders=False,
    )
    open(pendingPublish.path[0], "w").close()
    # Publish
    publishedFile = manager.publish(pendingPublish)[0]
    publishedFileString = str(publishedFile)

    # Store published file string in file
    # with open(pendingPublish.path[0], "a") as foo:
    os.environ['RDO_CURRENT_SHOW'] = ctx.project.name
    with RezContextProcess(ctx, application="nuke") as rez_process:
        LOG.info("Opening nuke script to update it")
        os.environ["RDO_CURRENT_SHOW"] = ctx.project.name
        os.environ["RDO_CURRENT_STEP"] = ctx.project.step.name
        nuke.scriptOpen(path)
        custom_setup(ctx)
        updateTemplate()
        root = nuke.root()
        publishedFileKnob = root.knob(PUBLISHED_FILE_KNOB)
        if not publishedFileKnob:
            publishedFileKnob = nuke.String_Knob(PUBLISHED_FILE_KNOB)
            root.addKnob(publishedFileKnob)
        publishedFileKnob.setValue(publishedFileString)
        LOG.warning("Knob Value %s", publishedFileKnob.value())

        # save the actual file
        nuke.scriptSave(pendingPublish.path[0])

    # close publish
    rdo_render_publisher.postRenderPublish(publishedFileString)

    # createNote.createNote(ctx, publishedFile)
    return True


@timeit
def publish_facility_template_to_shows(shows, tasks, dry_run=False):
    """Publish facility templates to given shows.

    Args:
        shows (list[str]): A list of shows
        tasks (list[str]): A list of tasks

    Returns:
        bool: True if everything went ok.
    """
    LOG.info("Starting process")
    success = True
    for show in shows:
        LOG.info("Processing show %s", show)
        for task, publish in fetch_publishes(tasks):
            ctx = rdo_context.Project(show, step=task)
            LOG.info("Making temp file for template")
            filename = os.path.basename(publish)
            temp_file = tempfile.mkstemp(
                suffix="from_{}".format(filename),
            )
            shutil.copy(publish, temp_file[1])
            LOG.info("Source file : {} copied to {}".format(publish, temp_file[1]))
            if dry_run:
                LOG.warning("Skipping publish")
                continue
            LOG.info("About to publish the template from {}".format(temp_file[1]))
            result = publish_template(ctx, "main", temp_file[1])
            if result:
                LOG.info("Success")
            else:
                LOG.error("Something went wrong")
            LOG.info("-" * 10)
        LOG.info("*" * 10)
    return success


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
def publish_facility_updated_template_to_show(shows, tasks, dry_run=False):
    """Publish facility templates to given shows.

    Args:
        shows (list[str]): A list of shows
        tasks (list[str]): A list of tasks

    Returns:
        bool: True if everything went ok.
    """
    LOG.info("Preparing to fetch, update, and publish facility template to shows")
    for show in shows:
        LOG.info("Processing show : %s", show)
        for task in tasks:
            LOG.info("\tProcessing task : %s", task)
            ctx = rdo_context.Project(show, step=task)
            # ctx = rdo_context.Shot(show, "dev", "dev_vfleury", step=task)
            LOG.info("\tContext is : %s", ctx)
            with RezContextProcess(ctx, application="nuke") as p:
                os.environ["RDO_CURRENT_SHOW"] = ctx.project.name
                os.environ["RDO_CURRENT_STEP"] = ctx.project.step.name
                # import pdbpp; pdbpp.set_trace()
                loadTemplate(ctx, "main")
                updateTemplate()
                template = getTemplatePublish(ctx, "main")
                template_path = template.version(manager.version.latest).path[0]
                LOG.info("\tTemplate path %s", template_path)
                current_write_node = nuke.toNode("rdo_shotgunWrite_01")
                if not current_write_node:
                    LOG.error("Template has no default write node.")
                    continue
                xpos, ypos = current_write_node.xpos(), current_write_node.ypos()

                write_rdo_node = nuke.createNode('WriteRdo', inpanel=False)
                setupWriteRdo(write_rdo_node)
                writeRdo._api.initializeNode(write_rdo_node)
                writeRdo._api.updateNode(write_rdo_node, profile=writeRdo.profiles.PrecompQC)

                write_rdo_node.setInput(0, current_write_node)

                write_rdo_node.setXYpos(xpos, ypos + 200)

                nuke.delete(current_write_node)
                if dry_run:
                    temp = tempfile.mkstemp(prefix=task, suffix=".nk")[1]
                    nuke.scriptSave(temp)
                    LOG.info("Saved at %s", temp)
                else:
                    LOG.info("Starting publish process")
                    publish.publishTemplate(ctx, step=task, variant="main")
                    LOG.info("Publish done")
            LOG.info("Done for task : %s", task)
        LOG.info("Done for show : %s", show)
        LOG.info("*" * 20)


@timeit
def main():
    """Main function"""
    parser = argparse.ArgumentParser(
        description="Publish facility template at show level."
    )
    parser.add_argument(
        "-s",
        "--shows",
        nargs="+",
        required=True,
        help="A list of shows to publish the template to."
    )
    parser.add_argument(
        "-t",
        "--tasks",
        nargs="+",
        default=['Layout (S)', 'Animation (S)', 'BMM (S)','Crowd Sim (S)',],
        help=" A list of tasks."
    )
    parser.add_argument(
        "--dry-run",
        help="Dry run the publish",
        action="store_true",
    )
    parser.add_argument(
        "--update_to_rdo_write",
        "-u",
        action="store_true",
        default=False,
        help="Publish the facility template to show level after updating it"
    )
    parser.add_argument(
        "--fetch",
        action="store_true",
        default=False
    )

    args = parser.parse_args()
    if args.fetch:
        for p in fetch_publishes(args.tasks):
            print p
            sys.exit(0)
    if args.update_to_rdo_write:
        publish_facility_updated_template_to_show(args.shows, args.tasks, args.dry_run)
    else:
        publish_facility_template_to_shows(args.shows, args.tasks, args.dry_run)

if __name__ == "__main__":
    main()

