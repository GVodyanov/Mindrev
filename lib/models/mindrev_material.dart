enum types {
  notes,
  orderedNotes,
  flashcards,
  graphs,
	mindmaps,
}

class MindrevMaterial {
  String name = '';
  types? type;
	String date = DateTime.now().toIso8601String();
	// ignore: prefer_typing_uninitialized_variables
	var contents;

	MindrevMaterial(this.name, this.type);

	void fill (var content) {
  	contents = content;
	}
}
