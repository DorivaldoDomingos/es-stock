import 'package:flutter/material.dart';
import '../controllers/artigo_controller.dart';
import '../controllers/utilizador_controller.dart';
import '../routes.dart';
import 'tema/app_theme.dart';
import 'widgets/cartoes.dart';
import 'widgets/botoes.dart';
import 'widgets/dados.dart';
class ArtigosView extends StatefulWidget {
  const ArtigosView({super.key});

  @override
  State<ArtigosView> createState() => _ArtigosViewState();
}

class _ArtigosViewState extends State<ArtigosView> {
  String _pesquisa = '';
  String _categoria = 'Todos';

  @override
  Widget build(BuildContext context) {
    return OuveDados(builder: _corpo);
  }

  Widget _corpo(BuildContext context) {
    final lista = ArtigoController.pesquisar(_pesquisa, _categoria);
    final categorias = ['Todos', ...ArtigoController.categorias];

    return Scaffold(
      appBar: AppBar(title: const Text('Artigos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _pesquisa = v),
              decoration: const InputDecoration(
                hintText: 'Pesquisar por nome ou código',
                prefixIcon: Icon(Icons.search, color: AppColors.muted),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categorias.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) => ChipFiltro(
                texto: categorias[i],
                selecionado: _categoria == categorias[i],
                onTap: () => setState(() => _categoria = categorias[i]),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: lista.isEmpty
                ? const Center(child: Text('Nenhum artigo encontrado.'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                    itemCount: lista.length + (UtilizadorController.gestor ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i == lista.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: BotaoPrincipal(
                            texto: '+ Novo artigo',
                            onPressed: () => Navigator.pushNamed(
                                context, Rotas.novoArtigo),
                          ),
                        );
                      }
                      final artigo = lista[i];
                      return ArtigoCard(
                        artigo: artigo,
                        onTap: () => Navigator.pushNamed(
                            context, Rotas.artigo,
                            arguments: artigo),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
