from rapidfuzz import fuzz


def normalize(text):
    return text.lower().replace(",", "").replace(".", "").split()


def word_similarity(spoken, slide):
    """
    Measures how many spoken words exist in the slide.
    Partial matching supported.
    """

    matched = 0

    for spoken_word in spoken:

        best = 0

        for slide_word in slide:

            score = fuzz.ratio(
                spoken_word,
                slide_word
            )

            best = max(best, score)

        if best >= 80:
            matched += 1

    # partial matching
    if len(spoken) == 0:
        return 0

    return matched / len(spoken)



def word_order_score(spoken, slide):
    """
    Checks whether words appear
    in the same order.
    """

    positions = []

    for word in spoken:

        best_position = None
        best_score = 0

        for index, slide_word in enumerate(slide):

            score = fuzz.ratio(
                word,
                slide_word
            )

            if score > best_score:
                best_score = score
                best_position = index

        if best_score >= 80:
            positions.append(best_position)


    if len(positions) < 2:
        return 1


    correct = 0

    for i in range(len(positions)-1):

        if positions[i] < positions[i+1]:
            correct += 1


    return correct / (len(positions)-1)



def slide_score(spoken, slide):

    similarity = word_similarity(
        spoken,
        slide
    )

    order = word_order_score(
        spoken,
        slide
    )

    return (
        similarity * 0.7
        +
        order * 0.3
    )



# TEST

spoken = normalize(
    input("TEXT: ")
)


slides = [
    "naomba uwepo wako enda",
    "nasi ewe bwana",
    "ewe bwana wa majeshi",
    "tu sikie kama",
    "huendi nasi hatutaki kutoka hapa",
    "kama huendi nasi"
]


results = []


for slide in slides:

    score = slide_score(
        spoken,
        normalize(slide)
    )

    results.append(score)



best = max(results)
index = results.index(best)


print("\nScores:")
for i, score in enumerate(results):
    print(
        f"Slide {i+1}: {score:.2f}"
    )


print("\nBest slide:", index + 1)
print("Confidence:", best)