# LanguageProcessing Module

## Purpose
Provide reusable Spanish text utilities for normalization, tokenization, and syllable counting. This module is used by ReadingPractice to compare spoken words and to filter words by syllable count.

## Key Types
- `TextNormalizer`: normalizes text to lowercase, removes punctuation and diacritics (except `ñ`).
- `WordTokenizer`: splits text into word tokens while preserving Spanish accents.
- `SpanishSyllableCounter`: heuristic offline syllable counter for Spanish words.

## Usage
Use `TextNormalizer` + `WordTokenizer` to compare speech transcripts with expected words. Use `SpanishSyllableCounter` to filter words by syllable count.
