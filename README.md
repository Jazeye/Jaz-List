# Pass-gen

**Wordlist Generator** is a powerful command-line tool designed for cybersecurity professionals and enthusiasts. It allows you to create and manipulate wordlists by combining multiple files, applying permutations, and performing character substitutions to generate custom wordlists for various security tasks like password cracking and penetration testing.

## Features

- **Combine Wordlists:** Merge multiple wordlists into one, eliminating duplicates.
- **Permutations:** Generate permutations of words to create more complex password combinations.
- **Character Substitutions:** Replace characters with common substitutions (e.g., `a` with `@`, `s` with `$`).
- **Filtering:** Filter words based on length to meet specific criteria.

## Requirements

- Python 3.6 or higher
- Linux-based system (Tested on Kali Linux)

## Installation

### Install from Source

1. **Clone the Repository:**

    ```bash
    git clone https://github.com/yourusername/wordlist-generator.git
    cd wordlist-generator
    ```

2. **Install the Tool:**

    ```bash
    sudo python3 setup.py install
    ```

### Install via Debian Package (Optional)

If you have created a .deb package:

```bash
sudo dpkg -i wordlist-generator_1.0_all.deb
```
## Usage
Once installed, you can run the tool from the command line:

```bash
wordlist-generator -w wordlist1.txt wordlist2.txt -o combined_wordlist.txt -p -s
```
## Command-Line Arguments
-w, --wordlists: Paths to input wordlists (required, multiple files supported).
-o, --output: Path to save the combined wordlist (required).
-p, --permutations: Apply permutations to combine words in different orders.
-s, --substitutions: Apply character substitutions (e.g., a -> @, s -> $).

## Example
```bash
wordlist-generator -w passwords.txt common_words.txt -o final_wordlist.txt -p -s
```
This command will:

-Combine the contents of passwords.txt and common_words.txt.
-Apply permutations to generate combinations of the words.
-Substitute common characters with their symbolic counterparts.
-Save the final wordlist to final_wordlist.txt.

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request or open an Issue on GitHub.

## License
This project is licensed under the MIT License. See the LICENSE file for details.

## Support
If you encounter any issues or have questions, feel free to open an issue on GitHub or contact me at 
