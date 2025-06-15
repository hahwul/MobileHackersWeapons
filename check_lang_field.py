import os
import yaml

def find_problematic_yaml_files(directory):
    problematic_files = []
    for filename in os.listdir(directory):
        if filename.endswith(".yaml") or filename.endswith(".yml"):
            filepath = os.path.join(directory, filename)
            try:
                with open(filepath, 'r') as f:
                    content = f.read()
                    # Handle potential empty files or files with only comments
                    if not content.strip():
                        print(f"Skipping empty file: {filepath}")
                        problematic_files.append(filepath) # Count empty files as problematic
                        continue

                    data = yaml.safe_load(content)

                    if data is None: # File contains only comments or is effectively empty after parsing
                        print(f"Skipping file with no parsable YAML data (e.g. only comments): {filepath}")
                        problematic_files.append(filepath) # Also problematic
                        continue

                    if 'lang' not in data or data.get('lang') is None or data.get('lang') == "":
                        problematic_files.append(filepath)
            except yaml.YAMLError as e:
                print(f"Error parsing YAML in file {filepath}: {e}")
                problematic_files.append(filepath) # If parsing fails, consider it problematic
            except Exception as e:
                print(f"An unexpected error occurred with file {filepath}: {e}")
                problematic_files.append(filepath) # Also problematic for other errors

    return problematic_files

if __name__ == "__main__":
    weapons_dir = "weapons"
    if not os.path.isdir(weapons_dir):
        print(f"Directory '{weapons_dir}' not found.")
    else:
        missing_lang_files = find_problematic_yaml_files(weapons_dir)
        if missing_lang_files:
            print("\nFiles with missing or empty 'lang' field:")
            for f_path in missing_lang_files:
                print(f_path)
        else:
            print(f"\nNo files found in '{weapons_dir}' with missing or empty 'lang' field.")

    # Store the list for the next step - creating a file with the results
    with open("problematic_yaml_files.txt", "w") as outfile:
        for f_path in missing_lang_files:
            outfile.write(f_path + "\n")
    print("\nList of problematic files saved to problematic_yaml_files.txt")
