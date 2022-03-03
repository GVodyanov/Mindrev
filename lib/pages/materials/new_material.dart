import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mindrev/extra/theme.dart';
import 'package:mindrev/services/db.dart';
import 'package:mindrev/services/text.dart';
import 'package:mindrev/services/text_color.dart';
import 'package:mindrev/widgets/widgets.dart';

import 'package:hexcolor/hexcolor.dart';
import 'package:sembast/utils/value_utils.dart';
import 'package:toml/toml.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NewMaterial extends StatefulWidget {
  const NewMaterial({ Key? key }) : super(key: key);

  @override
  State<NewMaterial> createState() => _NewMaterialState();
}

class _NewMaterialState extends State<NewMaterial> {

	Map routeData = {};
	Future text = readText('newMaterial');
	Future materials = rootBundle.loadString('assets/materials.toml');
	final _formKey = GlobalKey<FormState>();
	String? newMaterialName;
  int? selected;
  String? type;

	//function to create a new material
	Future<bool> newMaterial (String name, String type, String topic, String className) async {
  	print('$name $type $topic $className');
  	return true;	
	}

	List<Widget> displayMaterial (rawTOML, Color accentColor, Color contrastColor) {
  	var material = TomlDocument.parse(rawTOML).toMap();
  	List<Widget> result = [];
  	int j = material['materials'].length;
  	for (int i = j - 1; i >= 0; i--) {
    	if (selected == i) type = material['materials'][i]['name'];
    	result.add(
      	Padding (
        	padding: const EdgeInsets.all(8),
        	child: ElevatedButton (
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(20),
              primary: selected == i ? accentColor : theme.primary,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
          	child: Column (        	
            	crossAxisAlignment: CrossAxisAlignment.center,
            	children: [
  							SvgPicture.asset(
    							'assets/study_material_icons/${material['materials'][i]['icon']}.svg',
    							color: selected == i ? contrastColor : accentColor,
    						),
  							const SizedBox(height: 10, width: 100),
  							Text(material['materials'][i]['name'], style: TextStyle(color: selected == i ? contrastColor : theme.primaryText))
          		]
          	),
          	onPressed: () {
							setState(() {
  							selected = i;
							});              
          	},
        	)
      	)
    	);
  	}
    return result;
	}
	
  @override
  Widget build(BuildContext context) {
    routeData = routeData.isNotEmpty ? routeData : ModalRoute.of(context)?.settings.arguments as Map;
  	Color contrastColor = textColor(routeData['color']);
  	return FutureBuilder (
    	future: Future.wait([text, materials]),
    	builder: (BuildContext ctx, AsyncSnapshot<dynamic> snapshot) =>
    	snapshot.hasData ?
    		Scaffold (
          appBar: AppBar (
            foregroundColor: contrastColor,
            title: Text(snapshot.data![0]['title']),
            elevation: 10,
            centerTitle: true,
            backgroundColor: HexColor(routeData['color']),
          ),
          body: SingleChildScrollView (
            child: Center (
              child: Padding (
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox (
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Form (
                    key: _formKey,
                    child: Column (
                      children: [
                        TextFormField(
                          cursorColor: HexColor(routeData['color']),
                          style: defaultPrimaryTextStyle,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return snapshot.data![0]['errorNoText'];
                            }
                            return null;
                          },
                          onSaved: (value) {
                            setState(() {
                              newMaterialName = value;
                            });
                          },
                          decoration: defaultPrimaryInputDecoration(snapshot.data![0]['label']),
                        ),
                        const SizedBox(height: 20),
                        Material(
													borderRadius: const BorderRadius.all(Radius.circular(15)),
                          elevation: 8,
                          child: Padding (
                            padding: const EdgeInsets.all(8),
                            child: Column (
															children: [
                              	Text(snapshot.data![0]['type'], style: defaultPrimaryTextStyle),
                              	const SizedBox(height: 20, width: double.infinity),
                                Wrap (
                                  children: [
                                  	for (Widget i in displayMaterial(snapshot.data![1], HexColor(routeData['color']), contrastColor)) i
                                  ]
                                )
															]
                            ) 
                          )
                        ),
                        const SizedBox(height: 30),
                        coloredButton(snapshot.data![0]['submit'], (() async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState?.save();
                            if (newMaterialName != null && type != null) {
                              await newMaterial('$newMaterialName', '$type', routeData['selection'], routeData['className']);
                              Navigator.pop(context);
                              Navigator.pushReplacementNamed(context, '/topics',arguments: routeData);
                            }
                          }
                      	}), HexColor(routeData['color']), contrastColor)
                      ]
                    ) 
                  )
                )
              )
            )
          ),
    		)
    		: Scaffold (
      		//loading screen to be shown until Future is found
      		body: loading
    		)
  	);
  }
}
