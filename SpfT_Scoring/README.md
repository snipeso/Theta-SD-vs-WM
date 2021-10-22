# Instructions

1. Identify the filepaths where to get and save data in "spft_Parameters.m"
2. Run "AnonymizeAudio.m"
3. Do the scoring for every file
4. Run "SaveScoring.m"
5. Run "AssembleScoring.m" to get it all saved into a summary table.




## Scoring procedure

1. Going in numerical order, play audio with VLC media player, changing "playback" to the "slower" option
2. At every repetion of the sentence (Round1, Round2, etc) indicate with a lowercase "x" whenever the participant messes up the word in the corresponding column and row of the associated CSV file.
3. Mark with an "o" the last correct word.
4. Fill in all unmarked cells that correspond to correctly spoken words with "o".
5. Replay audio to check if correct.
6. Save!

### What counts as a mistake?
- Starting a word, stopping, then starting again
- repeating the word twice (if they start over from the beginning, just count one mistake)
- not finishing a word
- switched phonemes (e.g. she shold shea sells), mistake for every word
- skipped words, extra words
- incorrect order of words (mark as wrong just the first one), mistake just once
- completely wrong word (e.g. "many" instead of "much")
- stutter, incorrect starts (e.g. "sh-seashells")
- Switching two syllables of two different words counts as 2 mistakes (e.g. "Yew Nork")
- laughing in the middle of the word, or devolve into muttering


### what doesn't count as a mistake?
- pronouncing the word more slowly than usual, or hesitations
- small variations associated with accent 
- slurring but still recognizably correct
- systematic "mistakes" associated with accent or misunderstanding that occurs in all repetitions (e.g. "bettle" instead of "beetle")
- switching 2 words around only counts as 1 mistake
- slang or dialect pronunciations (e.g. "o' peppers" instead of "of peppers")