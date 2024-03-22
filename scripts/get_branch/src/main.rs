// A simple rust script to get the branch of a current repository
// Then if it matches a pattern :
// feature/ABC-123-foobar-baz trims to f/ABC-123-foobar
// bugfix/ABC-123-foobar-baz trims to f/ABC-123-foobar
// hotfix/ABC-123-foobar-baz trims to f/ABC-123-foobar
// would trim it-foobar-baz trims to f/ABC-123-foobar
use std::env;
use git2::Repository;

fn main() {
    let current_directory = env::current_dir();
    println!("Current directory {:?}", current_directory);
    let repo = match Repository::discover(current_directory.unwrap()) {
        Ok(repo) => repo,
        Err(_) => {
            println!("Not in a git repo");
            return;
        } 
    };
    println!("In a git repo");

    //let current_branch = repo.head().name().expect("REASON").unwrap();
    let current_branch = "";

    println!("Current branch is : {:?}", current_branch);

}

