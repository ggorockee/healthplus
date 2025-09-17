
import os
import sys
import tempfile
import shutil
from git import Repo
from ruamel.yaml import YAML

def update_yaml_file(repo_url, token, image_tag, branch="main"):
    """
    Clones a git repository, updates a YAML file with a new image tag,
    and pushes the changes back to the repository.
    """
    temp_dir = tempfile.mkdtemp()
    try:
        # Add token to repo_url for authentication
        authenticated_repo_url = repo_url.replace("https://", f"https://oauth2:{token}@")

        # Clone the repository
        print(f"Cloning repository {repo_url}...")
        repo = Repo.clone_from(authenticated_repo_url, temp_dir, branch=branch)
        print("Repository cloned successfully.")

        # Configure git user
        repo.config_writer().set_value("user", "name", "Gemini CI").release()
        repo.config_writer().set_value("user", "email", "gemini-ci@example.com").release()

        # Path to the YAML file
        yaml_file_path = os.path.join(temp_dir, "charts/argocd/applicationsets/valuefiles/dev/onedaypillo/values.yaml")

        if not os.path.exists(yaml_file_path):
            print(f"Error: File not found at {yaml_file_path}")
            return

        # Update the YAML file
        yaml = YAML()
        yaml.preserve_quotes = True
        with open(yaml_file_path, 'r') as f:
            data = yaml.load(f)

        print(f"Updating image tag to: {image_tag}")
        data["image"]["tag"] = image_tag

        with open(yaml_file_path, 'w') as f:
            yaml.dump(data, f)
        print("YAML file updated successfully.")

        # Commit and push the changes
        if repo.is_dirty(untracked_files=True):
            print("Committing changes...")
            repo.git.add(A=True)
            commit_message = f"ci: Update image tag to {image_tag} for onedaypillo"
            repo.index.commit(commit_message)
            
            print("Pushing changes...")
            origin = repo.remote(name="origin")
            origin.push()
            print("Changes pushed successfully.")
        else:
            print("No changes to commit.")

    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        # Clean up the temporary directory
        print(f"Cleaning up temporary directory: {temp_dir}")
        shutil.rmtree(temp_dir)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python update_infra_values.py <IMAGE_TAG> <INFRA_GITHUB_TOKEN>")
        sys.exit(1)

    image_tag_arg = sys.argv[1]
    infra_token_arg = sys.argv[2]
    
    infra_repo_url = "https://github.com/ggorockee/infra.git"

    update_yaml_file(infra_repo_url, infra_token_arg, image_tag_arg)
