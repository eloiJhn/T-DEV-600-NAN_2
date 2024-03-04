import 'package:flutter/material.dart';
import 'package:trelltech/repositories/authentification.dart';

class DiscoverAppView extends StatelessWidget {
  const DiscoverAppView({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Découvrir l\'application'),
        backgroundColor: const Color(0xFF1C39A1),
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            flex: 2, // Donnez plus de flex à l'image si nécessaire
            child: Center(
              child: Image.asset(
                'assets/images/presentation.png',
                // La taille de l'image sera relative à l'espace disponible
                fit: BoxFit.contain,
              ),
            ),
          ),
          const Flexible(
            flex: 1,
            child: Card(
              elevation: 0,
              child: ListTile(
                title:  Text('Gestion des espaces de travail'),
                subtitle:  Text('Créez, modifiez, supprimez et affichez vos espaces de travail.'),
                leading:  Icon(Icons.workspaces_outline),
              ),
            ),
          ),
                   const Flexible(
                     flex: 1,
                        child: Card(
                          elevation: 0,
                          child: ListTile(
                            title:  Text('Gestion des tableaux'),
                            subtitle:  Text('Gérez vos tableaux avec des modèles comme Kanban.'),
                            leading:  Icon(Icons.dashboard_customize),
                          ),
                        ),
                      ),
                    const Flexible(
                      flex: 1,
                        child: Card(
                          elevation: 0,
                          child: ListTile(
                            title:  Text('Gestion des listes'),
                            subtitle:  Text('Ajoutez, modifiez, supprimez et consultez vos listes.'),
                            leading:  Icon(Icons.list),
                          ),
                        ),
                      ),
                   const Flexible(
                     flex: 1,
                        child: Card(
                          elevation: 0,
                          child: ListTile(
                            title:  Text('Gestion des cartes'),
                            subtitle:  Text('Gérez vos cartes au sein des listes.'),
                            leading:  Icon(Icons.card_membership),
                          ),
                        ),
                      ),
                    const Flexible(
                      flex: 1,
                        child: Card(
                          elevation: 0,
                          child: ListTile(
                            title:  Text('Assignation de personnes aux cartes'),
                            subtitle:  Text('Assignez des tâches aux membres de votre équipe.'),
                            leading:  Icon(Icons.person_add_alt_1),
                          ),
                        ),
                      ),
                    Flexible(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: ElevatedButton(
                          onPressed: () => authenticateWithTrello(context),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(const Color(0xFF1C39A1)),
                            foregroundColor: MaterialStateProperty.all(Colors.white),
                          ),
                          child: const Text('Se connecter'),
                        ),
                      ),
                    ),
        ],
      ),
    );
  }
}
