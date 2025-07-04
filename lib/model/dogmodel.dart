class Dog{
  int id;
  String nome;
  int idade;

  Dog({
    required this.id,
    required this.nome,
    required this.idade,
  });

  Map<String, Object?> toMap(){
    return{'nome':nome, 'idade':idade};
  }

  @override
  String toString(){
    return"Dog:{id:$id, nome: $nome, idade:$idade}";
  }

}