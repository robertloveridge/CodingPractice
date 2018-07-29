#!/usr/bin/python

# Write a set of functions that translate text to Pig Latin.
# English is translated to Pig Latin by taking the first letter of every word,
# moving it to the end of the word and adding 'ay'.
# "The quick brown fox" becomes "Hetay uickqay rownbay oxfay".

VOWELS = ('a', 'e', 'i', 'o', 'u')

def convert_word(word):
    first_letter = word[0]
    if first_letter in VOWELS:
        return word + "hay"
    else:
        return word[1:] + word[0] + "ay"

def convert_sentence(sentence):
    list_of_words = sentence.split(' ')
    new_sentence = ""
    for word in list_of_words:
        new_sentence = new_sentence + convert_word(word)
        new_sentence = new_sentence + " "
    return new_sentence

print "Type in a sentence, and it'll get converted to Pig-Latin!"

text = raw_input()

print convert_sentence(text)
