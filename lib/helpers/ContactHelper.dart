import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String _tableContact = "contact";
final String _idColumn = "id";
final String _nomeColumn = "nome";
final String _celularColumn = "celular";
final String _emailColumn = "email";
final String _imgColumn = "img";

class ContactHelper {
	static final ContactHelper _instance = ContactHelper.internal();
	
	factory ContactHelper() => _instance;
	
	ContactHelper.internal();
	
	Database _db;
	
	Future<Database> get db async {
		if (_db != null)
			return _db;
		else {
			_db = await initDb();
			return _db;
		}
	}
	
	Future<Database> initDb() async {
		final dbPath = await getDatabasesPath();
		final path = join(dbPath, "createDB.db");
		
		var db = await openDatabase(path, version: 1, onCreate: createDB);
		return db;
	}
	
	Future<FutureOr<void>> createDB(Database db, int version) async {
		String SQL = "CREATE TABLE $_tableContact("
				"$_idColumn INTEGER PRIMARY KEY,"
				"$_nomeColumn TEXT,"
				"$_imgColumn TEXT,"
				"$_emailColumn TEXT,"
				"$_celularColumn TEXT"
				")";
		await db.execute(SQL);
		
		return db;
	}
	
	Future<Contatct> salvar(Contatct contatct) async {
		Database datab = await db;
		contatct.id = await datab.insert(_tableContact, contatct.toMap());
		return contatct;
	}
	
	Future<Contatct> get(int id) async {
		Database datab = await db;
		List<Map> contatos = await datab.query(_tableContact,
				where: "id = ?",
				whereArgs: [id]);
		Contatct contato = Contatct.fromMap(contatos.first);
		return contato;
	}
	
	delete(int id) async {
		Database datab = await db;
		await datab.delete(_tableContact,
				where: "id = ?",
				whereArgs: [id]);
	}
	
	update(Contatct contatct) async {
		Database datab = await db;
		var resultado = await datab.update(_tableContact,
				contatct.toMap(),
				where: "id = ?",
				whereArgs: [contatct.id]);
		
		return resultado;
	}
	
	Future<List<Contatct>>getAll()async{
		Database datab = await db;
		List<Map> map = await datab.query(_tableContact);
		
		List<Contatct> contatos = [];
		map.forEach((ctc) => contatos.add(Contatct.fromMap(ctc)));
		
		return contatos;
	}
}

//id nome email celular img
// 0  Henrique henrique@email.com 91987577195 hdauhduahduahduahduahd

class Contatct {
	int id;
	String nome;
	String email;
	String celular;
	String img;
	
	
	Contatct(this.nome, this.email, this.celular, this.img);
	
	
	Contatct.empty();
	
	Contatct.fromMap(Map map) {
		id = map[_idColumn];
		nome = map[_nomeColumn];
		email = map[_emailColumn];
		celular = map[_celularColumn];
		img = map[_imgColumn];
	}
	
	Map<String, dynamic> toMap() {
		Map<String, dynamic> contact = {
			_nomeColumn: nome,
			_emailColumn: email,
			_celularColumn: celular,
			_imgColumn: img
		};
		
		return contact;
	}
	
	@override
	String toString() {
		return this.toMap().toString();
	}
	
	
}
