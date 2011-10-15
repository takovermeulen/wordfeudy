#!/usr/bin/python
import re
import cgi
form = cgi.FieldStorage()
plaintext = open('dict.txt').read()
letters = form("letters").value
matches = re.findall('\n[%s]*a[%s]*\r' % (letters, letters), plaintext)
def check(letters, word):
    for l in letters:
        if letters.count(l) < word.count(l) and word.count(l) > 0:
            return False
    return True


bord_template = [
[('3W',''), (None,''), (None,''), ('2L',''), (None,''), (None,''), (None,''), ('3W',''), (None,''), (None,''), (None,''), ('2L',''), (None,''), (None,''), ('3W','')], 
[(None,''), ('2W',''), (None,''), (None,''), (None,''), ('3L',''), (None,''), (None,''), (None,''), ('3L',''), (None,''), (None,''), (None,''), ('2W',''), (None,'')], 
[(None,''), (None,''), ('2W',''), (None,''), (None,''), (None,''), ('2L',''), (None,''), ('2L',''), (None,''), (None,''), (None,''), ('2W',''), (None,''), (None,'')], 
[('2L',''), (None,''), (None,''), ('2W',''), (None,''), (None,''), (None,''), ('2L',''), (None,''), (None,''), (None,''), ('2W',''), (None,''), (None,''), ('2L','')], 
[(None,''), (None,''), (None,''), (None,''), ('2W',''), (None,''), (None,''), (None,''), (None,''), (None,''), ('2W',''), (None,''), (None,''), (None,''), (None,'')], 
[(None,''), ('3L',''), (None,''), (None,''), (None,''), ('3L',''), (None,''), (None,''), (None,''), ('3L',''), (None,''), (None,''), (None,''), ('3L',''), (None,'')], 
[(None,''), (None,''), ('2L',''), (None,''), (None,''), (None,''), ('2L',''), (None,''), ('2L',''), (None,''), (None,''), (None,''), ('2L',''), (None,''), (None,'')], 
[(None,''), (None, 'a'), (None,'a'), (None, 'n'), (None,''), (None,''), (None,'w'), (None,'a'), (None,'s'), (None,''), (None,''), (None,''), (None,''), (None,''), (None,'')], 
[(None,''), (None,''), ('2L',''), (None,''), (None,''), (None,''), ('2L',''), (None,''), ('2L',''), (None,''), (None,''), (None,''), ('2L',''), (None,''), (None,'')], 
[(None,''), ('3L',''), (None,''), (None,''), (None,''), ('3L',''), (None,''), (None,''), (None,''), ('3L',''), (None,''), (None,''), (None,''), ('3L',''), (None,'')], 
[(None,''), (None,''), (None,''), (None,''), ('2W',''), (None,''), (None,''), (None,''), (None,''), (None,''), ('2W',''), (None,''), (None,''), (None,''), (None,'')], 
[('2L',''), (None,''), (None,''), ('2W',''), (None,''), (None,''), (None,''), ('2L',''), (None,''), (None,''), (None,''), ('2W',''), (None,''), (None,''), ('2L','')], 
[(None,''), (None,''), ('2W',''), (None,''), (None,''), (None,''), ('2L',''), (None,''), ('2L',''), (None,''), (None,''), (None,''), ('2W',''), (None,''), (None,'')], 
[(None,''), ('2W',''), (None,''), (None,''), (None,''), ('3L',''), (None,''), (None,''), (None,''), ('3L',''), (None,''), (None,''), (None,''), ('2W',''), (None,'')], 
[('3W',''), (None,''), (None,''), ('2L',''), (None,''), (None,''), (None,''), ('3W',''), (None,''), (None,''), (None,''), ('2L',''), (None,''), (None,''), ('3W','')], 
]

bord_letters_only = [[w for (s,w) in row] for row in bord_template]

flipped = [[row[i] for row in bord_letters_only] for i in range(len(bord_template))]


def match_words_for_row(row):
    result = []
    if len("".join(row)) != 0:
        words_split = " ".join(row).strip().replace('  ', '$$').replace(' ', '').replace('$', "[%s]" % letters)

        word_re = "\n[%s]*%s[%s]*\r" % (letters, words_split, letters)
        matches = re.findall(word_re, plaintext)
        for m in matches:
            if check(letters, m):
                result.append(m)
    return result

en_scores = {'a' : 1, 'e' : 1, 'i' : 1, 'l' : 1, 'n' : 1, 'o' : 1, 'r' : 1, 's' : 1, 't' : 1, 'u' : 1,
 'd' : 2, 'g' : 2,
'b' : 3, 'c' : 3, 'm' : 3, 'p' : 3,
'f' : 4, 'h' : 4, 'v' : 4, 'w' : 4, 'y' : 4,
'k' : 5,
'j' : 8,  'x' : 8,
'q' : 10, 'z' : 10}

nl_scores = {'a' : 1,   'g' : 3,   'm' : 3,   's' : 2,   'y' : 8,
'b' : 3,   'h' : 4,   'n' : 1,    't' : 2,   'ij' : 4,
'c' : 5,   'i' : 1,   'o' : 1,   'u' : 4,   'z' : 4,
'd' : 2,   'j' : 4,   'p' : 3,   'v' : 4,   
'e' : 1,    'k' : 3,   'q' : '10',   'w' : 5,       
'f' : 4,   'l' : 3,   'r' : 2,   'x' : 8}
scores = nl_scores
def score_word(word):
    return sum(map(lambda x : scores[x], word))

letters = "gesen"
list_of_matches =  map(match_words_for_row, flipped) + map(match_words_for_row, bord_letters_only)
words = []
map(words.extend, list_of_matches)
words = set([w[1:-1] for w in words])
print "Content-Type: text/plain\n\n"
print sorted(words, key=score_word)