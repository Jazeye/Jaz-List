import itertools

def read_wordlist(file_path):
    with open(file_path, 'r') as file:
        words = file.read().splitlines()
    return words

def combine_wordlists(wordlists):
    combined = set()
    for wordlist in wordlists:
        combined.update(read_wordlist(wordlist))
    return sorted(combined)

def apply_permutations(words):
    return set([''.join(p) for p in itertools.permutations(words, 2)])

def apply_substitutions(word):
    substitutions = {
        'a': '@', 's': '$', 'i': '!', 'o': '0', 'e': '3'
    }
    for key, value in substitutions.items():
        word = word.replace(key, value)
    return word

def filter_wordlist(words, min_len=6, max_len=12):
    return [word for word in words if min_len <= len(word) <= max_len]

def create_wordlist(wordlists, output_file, apply_perm=False, apply_subs=False):
    words = combine_wordlists(wordlists)
    
    if apply_perm:
        words = list(apply_permutations(words))
    
    if apply_subs:
        words = [apply_substitutions(word) for word in words]
    
    words = filter_wordlist(words)
    
    with open(output_file, 'w') as file:
        for word in words:
            file.write(word + '\n')
    
    print(f"Wordlist saved to {output_file}")
