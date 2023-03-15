// ignore_for_file: file_names
import 'package:anotacoes/helper/AnotacaoHelper.dart';
import 'package:anotacoes/model/Anotacao.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();
  final _db = AnotacaoHelper();
  List<Anotacao> _anotacoes = [];


  _exibirTelaCadastro({Anotacao ?anotacao}){

    String textoSalvarAtualizar = "";

    if ( anotacao == null){//salvar
      textoSalvarAtualizar = "Salvar";
    }else{//atualizar
      _tituloController = TextEditingController(text: anotacao.titulo);
      _descricaoController = TextEditingController(text: anotacao.descricao);
      textoSalvarAtualizar = "Atualizar";
    }

    showDialog(
         
      context: context, 
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFfbff00),
          title: Text("$textoSalvarAtualizar Anotação"),
            titleTextStyle: const TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.w900
            ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _tituloController,
                  decoration: const InputDecoration(                                       
                    labelText: "Título",                  
                    labelStyle: TextStyle(                                            
                      color: Colors.black,                      
                    ),
                    hintText: "Digite título...",                    
                    hintStyle: TextStyle(
                      color: Colors.black,
                    )
                  ),
                  autofocus: true,
                ),
                TextField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(                                       
                    labelText: "Descrição",                  
                    labelStyle: TextStyle(                     
                      color: Colors.black,                      
                    ),
                    hintText: "Digite a descrição ...",                    
                    hintStyle: TextStyle(
                      color: Colors.black,
                    )
                  ),
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.black)
              ),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: (){
                _salvarAtualizarAnotacao(anotacaoSelecionada: anotacao);
                Navigator.pop(context);
              },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.black)
              ),
              child: Text(textoSalvarAtualizar),
            )
          ],
        );
      }
    );

  }

  _recuperarAnotacoes() async {

    List anotacoesRecuperadas = await _db.recuperarAnotacoes();
    
    List<Anotacao>? listTemp = [];
    for (var item in anotacoesRecuperadas ){

      Anotacao anotacao = Anotacao.fromMap(item);
      listTemp.add(anotacao);

    }

    setState(() {
      _anotacoes = listTemp!;
    });
    listTemp = null;
    //print("lista de anotacoes: " + anotacoesRecuperadas.toString());


  }

  _salvarAtualizarAnotacao({Anotacao ?anotacaoSelecionada}) async{

    String titulo =  _tituloController.text;
    String descricao = _descricaoController.text;
    
    if(anotacaoSelecionada == null){//salvar 

      Anotacao anotacao = Anotacao(titulo, descricao, DateTime.now().toString());
      int resultado = await _db.salvarAnotacao(anotacao);

    }else{//atualizar

      anotacaoSelecionada.titulo = titulo;
      anotacaoSelecionada.descricao = descricao;
      anotacaoSelecionada.data = DateTime.now().toString();
      int resultado = await _db.atualizarAnotacao(anotacaoSelecionada);

    }    

    _tituloController.clear();
    _descricaoController.clear();

    _recuperarAnotacoes();

  }

  _deletarAnotacao(int id) async {
    
    await _db.deletarAnotacao(id);    
    _recuperarAnotacoes();

  }

  _salvarAnotacaoSnack(Anotacao ultimaAnotacaoRemovida) async{
    Anotacao anotacao = Anotacao(ultimaAnotacaoRemovida.titulo,ultimaAnotacaoRemovida.descricao,DateTime.now().toString());
    int i = await _db.salvarAnotacaoSnackBar(anotacao);
    _recuperarAnotacoes();

  }

  _formatarData( String data){

    initializeDateFormatting("pt_BR");

    var formatador = DateFormat("HH:mm - d/MMM/y");

    DateTime dataConvertida = DateTime.parse(data);
    String dataFormatada = formatador.format(dataConvertida);

    return dataFormatada;

  }

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    _recuperarAnotacoes();
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      backgroundColor: const Color(0xFF435200),
      appBar: AppBar(
        title: const Text("Minhas Anotações"),
        centerTitle: true,
        backgroundColor: const Color(0xFFfbff00),
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
          
            child: ListView.builder(

              itemCount: _anotacoes.length,
              itemBuilder: (context, index){

                final anotacao = _anotacoes[index];

                return Dismissible(
                  background: Container(
                    color: Colors.red,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: const [
                        Icon(Icons.delete,
                        color: Colors.white,)
                      ],
                    ),
                  ),
                  
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    
                    Anotacao ultimaAnotacaoRemovida = anotacao;
                    _deletarAnotacao(anotacao.id!);
                    final snackbar = SnackBar(
                                content: const Text("Removido!"),
                                duration: const Duration(seconds: 5),
                                action: SnackBarAction(
                                  label: "Desfazer",
                                  onPressed: (){
                                    _salvarAnotacaoSnack(ultimaAnotacaoRemovida);
                                  },
                                ),
                            );
                    ScaffoldMessenger.of(context).showSnackBar(snackbar);
                    
                  },
                  key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
                  child: Card(
                  margin: const EdgeInsets.all(5),
                  shadowColor: const Color.fromARGB(255, 1, 1, 0),
                  color: const Color(0xFFfbff00),
                  child: ListTile(
                    title: Text(anotacao.titulo.toString()),
                    subtitle: Text("${_formatarData(anotacao.data.toString())} - ${anotacao.descricao}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        GestureDetector(
                          onTap: (){
                            _exibirTelaCadastro(anotacao: anotacao);
                          },
                          
                          child: const Padding(
                            padding: EdgeInsets.only(right: 5, top: 16, bottom: 16, left: 5),
                            child: Icon(
                              Icons.edit,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        
                      ],
                    ),
                  ),
                )
                );
                
              }
            )
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 255, 230, 0),
        foregroundColor: Colors.black,
        elevation: 5,
        onPressed: _exibirTelaCadastro,
        child: const Icon(Icons.add)
      ),
    );
  }
}