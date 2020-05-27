import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutterapp/helpers/ContactHelper.dart';
import 'package:image_picker/image_picker.dart';


class ContactPage extends StatefulWidget {
  final Contatct contact;

  const ContactPage({Key key, this.contact}) : super(key: key);

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  final focusNode = FocusNode();

  Contatct ctt = Contatct.empty();
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.contact != null) {
      isEditing = true;
      ctt = widget.contact;

      setState(() {
        _nameController.text = ctt.nome;
        _emailController.text = ctt.email;
        _phoneController.text = ctt.celular;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: popBack,
      child: Scaffold(
          appBar: AppBar(
            
            backgroundColor: Colors.red,
            title: Text(isEditing ? ctt.nome : "Novo contato"),
            centerTitle: true,
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor:
                isEditing ? Colors.deepPurpleAccent : Colors.redAccent,
            onPressed: () {
              if (_nameController.text.isNotEmpty) {
                ctt.nome = _nameController.text;
                ctt.celular = _phoneController.text;
                ctt.email = _emailController.text;
                //ctt.img = ""; //FIXME add path galeria
                Navigator.pop(context, ctt);
              }
            },
            label: Text(isEditing ? "Atualizar" : "Salvar"),
            icon: Icon(!isEditing ? Icons.person_add : Icons.mode_edit),
          ),
          body: SingleChildScrollView(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: () async {
                      File img = await ImagePicker.pickImage(source: ImageSource.gallery);
                      setState(() {
                        ctt.img = img != null ? img.path:"";
                      });
                    },
                    child: Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: ctt.img != null && ctt.img.isNotEmpty
                                    ? FileImage(File(ctt.img))
                                    : AssetImage("imgs/person.png"))),
                      ),
                    ),
                  ),
                  _input("Nome", TextInputType.text, _nameController,
                      icone: Icons.person),
                  _input("E-mail", TextInputType.emailAddress, _emailController,
                      icone: Icons.email),
                  _input("Celular", TextInputType.phone, _phoneController,
                      icone: Icons.phone_iphone),
                ],
              ))),
    );
  }

  Widget _input(String hint, TextInputType type, controller, {IconData icone}) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextFormField(
        validator: validacao,
        autovalidate: true,
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
            hoverColor: Colors.red,
            labelText: hint,
            icon: Icon(
                  icone,
                  color: Colors.red,
                ) ??
                null,
            border: OutlineInputBorder()),
      ),
    );
  }

  String validacao(String value) {
    if (value.isEmpty) {
      return "Campo não pode estar vazio !";
    }
  }

  Future<bool> popBack() {
    if (ctt.nome != null) {
      showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: Text("Descartar modificações"),
              content: Text("Se sair tudo será perdido !"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Cancelar"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(child: Text("Sair"), onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }),
              ],
            );
          });
      Future.value(false);
    }else{
      Navigator.pop(context);
      Future.value(true);
    }
  }
  
}
