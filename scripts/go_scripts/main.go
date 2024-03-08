package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"os/exec"
	"strings"

	"github.com/akamensky/argparse"
	"github.com/go-git/go-git/v5"
	"github.com/go-git/go-git/v5/plumbing"
)

// Constants declaration
const (
	USER_URL_TEMPLATE string = "https://bitbucket.rodeofx.com/rest/api/1.0/users/vfleury/repos/home_repo/pull-requests"
	URL_TEMPLATE      string = "https://bitbucket.rodeofx.com/rest/api/1.0/projects/%s/repos/%s/pull-requests"
	PR_TEMPLATE       string = `#### Purpose of the PR

#### Overview of the changes

#### Type of feedback wanted

#### Where should the reviewer start looking at?

#### Potential risks of this change

#### Relationship with other PRs
`
)

var DEFAULT_REVIEWERS = []map[string]map[string]string{
	{"user": {"name": "bramoul"}},
	{"user": {"name": "jcarvalho"}},
	{"user": {"name": "agjolly"}},
	{"user": {"name": "andyl"}},
	{"user": {"name": "jdubuisson"}},
	{"user": {"name": "alima"}},
	{"user": {"name": "lchikar"}},
	{"user": {"name": "ldepoix"}},
	{"user": {"name": "elabrosse"}},
}

func main() {
	parser := argparse.NewParser("create_pr", "Creates a PR from the CLI in GO !")

	dry_run := parser.Flag("d", "dry-run", &argparse.Options{Help: "Run through the process without creating the PR"})
	empty := parser.Flag("e", "empty-reviewers", &argparse.Options{Help: "Empty default reviewers"})
	publish := parser.Flag("p", "publish_pr", &argparse.Options{Help: "Publish PR", Default: true})

	err := parser.Parse(os.Args)
	if err != nil {
		// In case of error print error and print usage
		// This can also be done by passing -h or --help flags
		fmt.Print(parser.Usage(err))
	}
	// Finally print the collected string
	//fmt.Println(*empty)
	if *dry_run == true {
		fmt.Println(get_token())
	}

	if *empty == true {
		fmt.Println("Clear reviewers")
	}

	if *publish == true {
		fmt.Println("Publishing PR !")
	}

	//fmt.Println(DEFAULT_REVIEWERS[0])
	url, err := get_repo_url()
	fmt.Println("URL is ", url)
	//fmt.Println("Err is ", err)
	fmt.Println("Editor is", get_editor())
	//editor_input, err := raw_input_editor(PR_TEMPLATE, "vim")
	//fmt.Println("Raw input ", editor_input)
	data := request_data()
	if *publish {
		publish_pr(url, data)
	}
}

func get_token() string {

	token_path := os.Getenv("HOME") + "/token.tk"
	fmt.Println("Token path is ", token_path)
	token, err := os.ReadFile(token_path)
	if err != nil {
		fmt.Println("Panic ! No token found")
	}
	return string(token)
}

func get_repo() (*git.Repository, error) {
	current_directory, err := os.Getwd()
	if err != nil {
		fmt.Println("Current directory could not be found?")
	}
	fmt.Println("Current directory is", current_directory)

	//repo, err := git.PlainOpen(current_directory)
	options := git.PlainOpenOptions{DetectDotGit: true}
	repo, err := git.PlainOpenWithOptions(current_directory, &options)
	if err != nil {
		return nil, err
	}

	return repo, nil
}

// Build the REST API Endpoint from the git repository information
func get_repo_url() (string, error) {
	repo, err := get_repo()
	if err != nil {
		fmt.Println("Could not retrieve a repository from the current working directory")
		panic(err)
	}

	remotes, err := repo.Remotes()
	if err != nil || len(remotes) == 0 {
		fmt.Println("Repository has no remote ...")
		return "", err
	}

	remote := remotes[0]
	config_url := remote.Config().URLs[0]

	parts := strings.Split(config_url, "/")
	project := parts[len(parts)-2]
	slug_name := strings.Split(parts[len(parts)-1], ".git")[0]

	formatted_url := fmt.Sprintf(URL_TEMPLATE, project, slug_name)

	return formatted_url, nil

}

func get_editor() string {
	editor := os.Getenv("VISUAL")

	if editor != "" {
		return editor
	}

	editor = os.Getenv("EDITOR")

	if editor != "" {
		return editor
	}

	return "vim"
}

func raw_input_editor(default_content string, editor string) (string, error) {
	tempfile, err := os.CreateTemp("", "temp_pr")
	if err != nil {
		fmt.Println("Could not create tempfile", err)
	}
	defer tempfile.Close()
	fmt.Println("Tempfile :", tempfile.Name())
	if default_content != "" {
		fmt.Println("Writing default data")
		_, err = tempfile.WriteString(default_content)
		if err != nil {
			return "", fmt.Errorf("failed to write default content to temporary file: %w", err)
		}
	}

	// Opening the editor
	cmd := exec.Command(editor, tempfile.Name())
	cmd.Stdin = os.Stdin
	cmd.Stderr = os.Stderr
	cmd.Stdout = os.Stdout
	err = cmd.Run()
	fmt.Println(err)

	// Reading back the file content
	raw_input, err := os.ReadFile(tempfile.Name())
	return string(raw_input), nil
}

func request_data() []byte {
	repo, err := get_repo()
	if err != nil {
		fmt.Errorf(string(err.Error()))
	}
	// Get the reference to the current HEAD commit
	headRef, err := repo.Head()
	if err != nil {
		panic(err)
	}
	branch := strings.Split(headRef.String(), "refs/heads/")[1]
	fmt.Println("Branch", branch)

	// Defining default branch :
	default_destination_branch := "refs/heads/dev"
	branches, err := repo.Branches()
	// Making a map
	repo_branches := make(map[string]struct{})
	branches.ForEach(func(b *plumbing.Reference) error {
		short_name := strings.Split(b.String(), "refs/heads/")[1]
		fmt.Println("Shortname ", short_name)
		repo_branches[short_name] = struct{}{}
		return nil
	})

	// Checking if dev branch exists in the repo. Otherwise the master is the default
	// is master
	fmt.Println("Is there a dev branch ?", repo_branches["dev"])
	if _, ok := repo_branches["dev"]; ok == false {
		fmt.Println("No dev branch, defaulting merge branch to master")
		default_destination_branch = "refs/heads/master"
	}
	fmt.Println("Default branch is ", default_destination_branch)

	//logs, err := repo.Log(&git.LogOptions{From: headRef.Hash()})
	title, err := repo.CommitObject(headRef.Hash())
	fmt.Println("PR TITLE", title.Message)

	description, err := raw_input_editor(PR_TEMPLATE, "vim")
	if err != nil {
		panic(err)
	}

	data := map[string]interface{}{
		"description": description,
		"toRef": map[string]interface{}{
			"id": default_destination_branch,
		},
		"state":     "OPEN",
		"title":     title,
		"reviewers": DEFAULT_REVIEWERS,
	}

	json_data, err := json.Marshal(data)

	fmt.Printf("%s\n", json_data)

	return json_data
}

func publish_pr(url string, data []byte) {
	fmt.Println("Publishing PR")
	log.Printf("URL is %s", url)
	log.Printf("Data is %s", data)

	headers := map[string]string{
		"authorization": "Bearer "+get_token(),
		"content-type":  "application/json",
	}

	payload, err := json.Marshal(data)
	if err != nil {
		log.Fatal("Oh no")
	}
	fmt.Println(headers)
	//fmt.Println(payload)

	client := &http.Client{}

	req, err := http.NewRequest(http.MethodPut, url, bytes.NewBuffer(payload))
	if err != nil {
		panic(err)
	}

	req.Header.Set("Authorization", headers["authorization"])
	req.Header.Set("Content-Type", "application/json")

	fmt.Println(req.Header)

	res, err := client.Do(req)
	if err != nil {
		panic(err)
	}

	defer res.Body.Close()

	body, err := io.ReadAll(res.Body)
	if err != nil {
		log.Fatal(err)
	}
	log.Println(string(body))

}

func test_publish_pr(url string, data []byte) {
	url = "http://example.com"
	req, err := http.Get(url)
	if err != nil {
		panic(err)
	}
	defer req.Body.Close()
	body, err := io.ReadAll(req.Body)
	if err != nil {
		log.Fatal(err)
	}

	log.Println(string(body))
}
