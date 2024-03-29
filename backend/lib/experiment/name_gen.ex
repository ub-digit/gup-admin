defmodule Experiment.NameGen do
  def generate() do
    noun = nouns() |> Enum.random()
    adjective = adjectives() |> Enum.random()
    noun2 = nouns() |> Enum.random()
    preposition = prepositions() |> Enum.random()

    [adjective, noun, preposition, noun2]
    |> Enum.join(" ")
  end

  def nouns do
    [
      "Atom",
      "Molecule",
      "Cell",
      "Organism",
      "DNA",
      "RNA",
      "Gene",
      "Protein",
      "Enzyme",
      "Catalyst",
      "Chemical",
      "Compound",
      "Element",
      "Mineral",
      "Isotope",
      "Particle",
      "Electron",
      "Proton",
      "Neutron",
      "Photon",
      "Energy",
      "Force",
      "Mass",
      "Gravity",
      "Light",
      "Sound",
      "Wave",
      "Frequency",
      "Amplitude",
      "Phase",
      "Magnetism",
      "Electric field",
      "Magnetic field",
      "Current",
      "Voltage",
      "Resistance",
      "Capacitance",
      "Inductance",
      "Impedance",
      "Transformer",
      "Generator",
      "Motor",
      "Battery",
      "Circuit",
      "Transistor",
      "Diode",
      "Microprocessor",
      "Computer",
      "Software",
      "Algorithm",
      "Data",
      "Information",
      "Knowledge",
      "Wisdom",
      "Intelligence",
      "Consciousness",
      "Perception",
      "Memory",
      "Attention",
      "Emotion",
      "Motivation",
      "Personality",
      "Behavior",
      "Cognition",
      "Language",
      "Speech",
      "Grammar",
      "Syntax",
      "Semantics",
      "Pragmatics",
      "Literature",
      "Poetry",
      "Drama",
      "Fiction",
      "Nonfiction",
      "History",
      "Geography",
      "Anthropology",
      "Sociology",
      "Psychology",
      "Philosophy",
      "Logic",
      "Epistemology",
      "Metaphysics",
      "Ethics",
      "Aesthetics",
      "Biology",
      "Ecology",
      "Zoology",
      "Botany",
      "Anatomy",
      "Physiology",
      "Pharmacology",
      "Immunology",
      "Epidemiology",
      "Biotechnology",
      "Biochemistry",
      "Neuroscience",
      "Physics",
      "Chemistry"
    ]
  end

  def adjectives do
    [
      "Abiding",
      "Abundant",
      "Accurate",
      "Adaptable",
      "Adventurous",
      "Affectionate",
      "Agile",
      "Alert",
      "Altruistic",
      "Ambitious",
      "Amiable",
      "Analytical",
      "Angelic",
      "Animated",
      "Appreciative",
      "Artistic",
      "Assertive",
      "Attentive",
      "Authentic",
      "Awesome",
      "Balanced",
      "Beautiful",
      "Benevolent",
      "Blissful",
      "Brave",
      "Bright",
      "Brilliant",
      "Bubbly",
      "Calm",
      "Capable",
      "Carefree",
      "Caring",
      "Cautious",
      "Charismatic",
      "Charming",
      "Cheerful",
      "Classy",
      "Clean",
      "Clear",
      "Clever",
      "Compassionate",
      "Competent",
      "Composed",
      "Confident",
      "Considerate",
      "Consistent",
      "Content",
      "Cooperative",
      "Courageous",
      "Creative",
      "Credible",
      "Curious",
      "Dainty",
      "Daring",
      "Dazzling",
      "Decisive",
      "Dedicated",
      "Delightful",
      "Dependable",
      "Determined",
      "Devoted",
      "Dignified",
      "Diligent",
      "Diplomatic",
      "Discerning",
      "Discreet",
      "Dynamic",
      "Eager",
      "Earnest",
      "Easygoing",
      "Eclectic",
      "Effective",
      "Efficient",
      "Elegant",
      "Empathetic",
      "Energetic",
      "Enthusiastic",
      "Ethical",
      "Euphoric",
      "Excellent",
      "Exuberant",
      "Fabulous",
      "Faithful",
      "Fanciful",
      "Fantastic",
      "Fearless",
      "Feisty",
      "Flamboyant",
      "Flexible",
      "Focused",
      "Friendly",
      "Fun-loving",
      "Funny",
      "Gentle",
      "Genuine",
      "Giving",
      "Glorious",
      "Good-natured",
      "Graceful",
      "Grateful"
    ]
  end

  def prepositions do
    [
      "About",
      "Above",
      "Across",
      "After",
      "Against",
      "Along",
      "Amid",
      "Among",
      "Around",
      "At",
      "Before",
      "Behind",
      "Below",
      "Beneath",
      "Beside",
      "Between",
      "Beyond",
      "But",
      "By",
      "Concerning",
      "Considering",
      "Despite",
      "Down",
      "During",
      "Except",
      "For",
      "From",
      "In",
      "Inside",
      "Into",
      "Like",
      "Near",
      "Of",
      "Off",
      "On",
      "Onto",
      "Out",
      "Outside",
      "Over",
      "Past",
      "Regarding",
      "Round",
      "Since",
      "Through",
      "Throughout",
      "To",
      "Toward",
      "Under",
      "Underneath",
      "Until",
      "Unto",
      "Up",
      "Upon",
      "With",
      "Within",
      "Without"
    ]
  end
end
