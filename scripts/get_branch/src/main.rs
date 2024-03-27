// A simple rust script to get the branch of a current repository
// Then if it matches a pattern :
// feature/ABC-123-foobar-baz trims to f/ABC-123-foobar
// bugfix/ABC-123-foobar-baz trims to f/ABC-123-foobar
// hotfix/ABC-123-foobar-baz trims to f/ABC-123-foobar
// would trim it-foobar-baz trims to f/ABC-123-foobar
use git2::Repository;
use std::env;
use std::time::Instant;

fn main() {
    let start = Instant::now();
    let current_directory = env::current_dir();
    //println!("Current directory {:?}", current_directory);
    let repo = match Repository::discover(current_directory.unwrap()) {
        Ok(repo) => repo,
        Err(_) => {
            println!("Not in a git repo");
            return;
        }
    };

    let binding = repo.head().expect("REASON");
    let current_branch = binding.name().unwrap().to_string();

    //let rev = repo.revparse_single("HEAD").expect("Error");
    //let head = match repo.revparse("HEAD") {
    //Ok(head) => head,
    //Err(_) => panic!(),
    //};

    let clean = current_branch.replace("refs/heads/", "");

    let branch_parts: Vec<_> = clean.split('/').collect();
    //for part in branch_parts {
    //println!("{}", part);
    //}
    if branch_parts.len() > 1 {
        let branch_type = &branch_parts[0][0..1];
        let branch_name_parts = &branch_parts[1].split('-').collect::<Vec<_>>();
        let max = if branch_parts.len() > 3 {
            3
        } else {
            branch_parts.len()
        };
        let branch_name = branch_name_parts[0..max].join("-").to_string();
        println!("Branch ticket {}/{}", branch_type, branch_name);
    } else {
        println!("Branch {}", branch_parts[0])
    }
    let duration = start.elapsed();
    println!("Done in {:?}", duration);
}
