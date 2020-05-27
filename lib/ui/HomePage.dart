import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/helpers/ContactHelper.dart';
import 'package:flutterapp/ui/ContactPage.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrdemOption {ordemaz, ordemza}


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper cHelper = ContactHelper();
  List<Contatct> contatineos = [];

  get loadContat {
    
    return ;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //cHelper.salvar(Contatct("Henrique", "henrique@email.com", "91987577195", ""));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: <Widget>[
          PopupMenuButton<OrdemOption>(
            onSelected: _orderList,
            itemBuilder: (BuildContext context) {
            return <PopupMenuEntry<OrdemOption>>[
              const PopupMenuItem(child: Text("Ordernar de A-Z"),value: OrdemOption.ordemaz,),
              const PopupMenuItem(child: Text("Ordernar de Z-A"),value: OrdemOption.ordemza,)
            ];
          },)
        ],
        title: Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Contatct>>(
        future: loadContat,
        builder: (ctx, snp) {
          if (snp.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snp.hasData) {
            return bodyContatos(snp.data);
          } else {
            return Container(
              child: Center(
                child: Text("Nenhum contato cadastrado"),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.red,
        onPressed: () {
          contactPage();
        },
        label: Text("Adicionar"),
        icon: Icon(Icons.person_add),
      ),
    );
  }

  ListView bodyContatos(List<Contatct> contatineos) {
    return ListView.builder(
        itemCount: contatineos.length,
        padding: EdgeInsets.all(16),
        itemBuilder: (ctx, index) {
          Contatct c = contatineos.elementAt(index);
          return _contactCard(c);
        });
  }

  Widget _contactCard(Contatct c) {
    //c.img = c.img.trim()??"";
    return GestureDetector(
      onTap: (){
        //contactPage(contato:c);
        showOptions(context, c);
      },
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(9),
          child: Row(
            children: <Widget>[
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: c.img != null && c.img.isNotEmpty
                            ? FileImage(File(c.img))
                            : AssetImage("imgs/person.png"))),
              ),
              Padding(
                padding: EdgeInsets.only(left: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "${c.nome ?? ""}",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text("${c.email ?? ""}"),
                    Text("${c.celular ?? ""}"),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void contactPage({Contatct contato}) async {
    final contact = await Navigator.push(context, MaterialPageRoute(builder: (_)=>ContactPage(contact: contato,)));
    if(contact!=null){
      if(contato != null){
        await cHelper.update(contact);
      }else{
        await cHelper.salvar(contact);
      }
    }
    cHelper.getAll();
    setState(() { });
  }

  void showOptions(BuildContext context, Contatct contatct) {
    showModalBottomSheet(context: context, builder: (contexto){
      return BottomSheet(builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlatButton(
                  onPressed: () {
                    launch("tel:${contatct.celular}");
                    Navigator.pop(context);
                  },
                  child: Text("Ligar", style: TextStyle(color: Colors.red, fontSize: 20.0),),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    contactPage(contato: contatct);
                  },
                  child: Text("Editar", style: TextStyle(color: Colors.red, fontSize: 20.0),),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    cHelper.delete(contatct.id);
                    setState(() { });
                  },
                  child: Text("Excluir", style: TextStyle(color: Colors.red, fontSize: 20.0),),
                ),
              )
            ],
          ),);
      }, onClosing: () {
      
      },);
    });
  }

  Future<void> _orderList(OrdemOption op) async {
    var l = await cHelper.getAll();
    switch(op){
      case OrdemOption.ordemaz:
        return l.sort((a,b)=>a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
        break;
      case OrdemOption.ordemza:
        return l.sort((a,b)=>b.nome.toLowerCase().compareTo(a.nome.toLowerCase()));
        break;
    }
  }
  
}
