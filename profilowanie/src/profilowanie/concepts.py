"""Hand-written concept bank for TweetEval-emoji.

Each concept is (short name, NLI hypothesis). The hypothesis is scored against
every tweet by a zero-shot NLI model; P(entailment) is the concept pseudo-label.
"""

CONCEPTS: list[tuple[str, str]] = [
    # --- affect ---
    ("romantic_love", "This tweet expresses romantic love."),
    ("affection_friend_family", "This tweet expresses affection for friends or family."),
    ("joy", "This tweet expresses joy or happiness."),
    ("humor", "This tweet is funny or is a joke."),
    ("laughing_at", "The author is laughing at something."),
    ("sarcasm", "This tweet is sarcastic or ironic."),
    ("sadness", "This tweet expresses sadness."),
    ("anger", "This tweet expresses anger or annoyance."),
    ("gratitude", "This tweet expresses gratitude or thankfulness."),
    ("pride", "This tweet expresses pride in an achievement."),
    ("excitement", "This tweet expresses excitement or anticipation."),
    ("admiration", "This tweet expresses admiration for someone or something."),
    ("flirting", "This tweet is flirtatious or teasing."),
    ("missing_someone", "The author misses someone or something."),
    ("confidence", "This tweet shows confidence or bragging."),
    ("calm", "This tweet expresses calm or relaxation."),
    # --- topic ---
    ("christmas", "This tweet is about Christmas or the winter holidays."),
    ("patriotism", "This tweet is about the United States or patriotism."),
    ("politics", "This tweet is about politics or an election."),
    ("photography", "This tweet is about a photo, a photographer or a photo shoot."),
    ("sun_weather", "This tweet is about sunny or warm weather."),
    ("beach_summer", "This tweet is about the beach, summer or a vacation."),
    ("nature", "This tweet is about nature or a landscape."),
    ("sunset_sky", "This tweet is about a sunset, a sunrise or the sky."),
    ("food_drink", "This tweet is about food or drinks."),
    ("music", "This tweet is about music, a song or a concert."),
    ("sports", "This tweet is about sports or a sports team."),
    ("fitness", "This tweet is about exercise or a workout."),
    ("party_nightlife", "This tweet is about a party or a night out."),
    ("birthday", "This tweet is about a birthday or an anniversary."),
    ("wedding", "This tweet is about a wedding or an engagement."),
    ("family", "This tweet mentions a family member."),
    ("friends", "This tweet is about spending time with friends."),
    ("partner", "This tweet is about a boyfriend, girlfriend, husband or wife."),
    ("baby_child", "This tweet is about a baby or a child."),
    ("pets", "This tweet is about a pet or an animal."),
    ("fashion_beauty", "This tweet is about fashion, makeup or appearance."),
    ("work_business", "This tweet is about work or business."),
    ("school", "This tweet is about school, college or graduation."),
    ("travel", "This tweet is about traveling or visiting a place."),
    ("city_location", "This tweet names a specific city or venue."),
    ("religion", "This tweet is about God, faith or being blessed."),
    ("art_design", "This tweet is about art, design or decoration."),
    ("shopping", "This tweet is about shopping or a product."),
    # --- style / speech act ---
    ("slang", "This tweet uses slang or very informal language."),
    ("intensity", "This tweet says that something is intense, extreme or amazing."),
    ("authenticity", "This tweet says that something is real, true or one hundred percent."),
    ("promotion", "This tweet advertises or promotes something."),
    ("event_announcement", "This tweet announces or reports on an event."),
    ("addresses_person", "This tweet is addressed directly to another person."),
    ("self_focused", "This tweet is mainly about the author."),
    ("past_memory", "This tweet recalls a memory or a past event."),
]

NAMES = [name for name, _ in CONCEPTS]
HYPOTHESES = [hyp for _, hyp in CONCEPTS]
