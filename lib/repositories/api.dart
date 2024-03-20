import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:trelltech/models/board.dart';
import 'package:trelltech/models/trello_board_template.dart';
import 'package:trelltech/models/trello_organization.dart';

import '../models/trello_card.dart';
import '../models/trello_list.dart';

/// Fetches the user's ID from Trello.
///
/// This function calls the Trello API to fetch the user's ID.
/// It requires the user's API key and token.
/// Returns the user's ID.
Future<String> getTrelloClientID(String apiKey, String token) async {
  final response = await http.get(
    Uri.parse('https://api.trello.com/1/members/me?key=$apiKey&token=$token'),
  );

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    return data['id'];
  } else {
    throw Exception('Failed to load boards');
  }
}

Future<dynamic> getMember(String apiKey, String token, String memberId) async {
  final response = await http.get(
    Uri.parse(
        'https://api.trello.com/1/members/$memberId?key=$apiKey&token=$token'),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load member');
  }
}

Future<dynamic> getMembersFromCard(
    String apiKey, String token, String cardId) async {
  final response = await http.get(
    Uri.parse(
        'https://api.trello.com/1/cards/$cardId/members?key=$apiKey&token=$token'),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load members');
  }
}

Future<dynamic> getMembersFromBoard(
    String apiKey, String token, String boardId) async {
  final response = await http.get(
    Uri.parse(
        'https://api.trello.com/1/boards/$boardId/members?key=$apiKey&token=$token'),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load members');
  }
}

Future<dynamic> addMemberToCard(
    String apiKey, String token, String cardId, String memberId) async {
  final response = await http.post(
    Uri.parse(
        'https://api.trello.com/1/cards/$cardId/idMembers?key=$apiKey&token=$token&value=$memberId'),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to add member');
  }
}

/// Create a new board on Trello.
/// This function calls the Trello API to create a new board.
/// It requires the user's API key, token, and the name of the board.
/// Returns the ID of the new board.
/// Throws an exception if the request fails.
Future<Board> createBoard(String apiKey, String token, String name,
    String description, String workspaceId, String? templateId) async {
  if (templateId != null) {
    final response = await http.post(
      Uri.parse(
          'https://api.trello.com/1/boards?key=$apiKey&token=$token&name=$name&desc=$description&idBoardSource=$templateId&idOrganization=$workspaceId'),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return Board.fromJson(data);
    } else {
      throw Exception('Failed to create board');
    }
  } else {
    final response = await http.post(
      Uri.parse(
          'https://api.trello.com/1/boards?key=$apiKey&token=$token&name=$name&desc=$description&idOrganization=$workspaceId'),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data['id'];
    } else {
      throw Exception('Failed to create board');
    }
  }
}

/// Fetches the user's boards from Trello.
///
/// This function calls the Trello API to fetch the user's boards.
/// It requires the user's API key, token, and the workspace ID.
/// Returns a list of boards.
Future<List<Board>> getBoards(
    String apiKey, String token, String workspaceId) async {
  final response = await http.get(
    Uri.parse(
        'https://api.trello.com/1/organizations/$workspaceId/boards?key=$apiKey&token=$token'),
  );

  if (response.statusCode == 200) {
    var boardsJson = jsonDecode(response.body) as List;
    print(response.body);
    return boardsJson.map((board) => Board.fromJson(board)).toList();
  } else {
    throw Exception('Failed to load boards');
  }
}

Future<void> updateBoard(
    String apiKey, String? token, String boardId, Board board) async {
  final response = await http.put(
    Uri.parse(
        'https://api.trello.com/1/boards/$boardId?key=$apiKey&token=$token&name=${board.name}'),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to update board');
  }
}

/// Fetches the user's workspaces from Trello.
///
/// This function calls the Trello API to fetch the user's workspaces.
/// It requires the user's API key, token, and client ID.
/// Returns a list of workspaces.
Future<List<dynamic>> getWorkspaces(
    String apiKey, String? token, String? clientId) async {
  final response = await http.get(
    Uri.parse(
        'https://api.trello.com/1/members/$clientId/organizations?key=$apiKey&token=$token'),
  );

  if (response.statusCode == 200) {
    print(response.body);
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load workspace');
  }
}

/// Fetches the lists of a specific board from Trello.
///
/// This function calls the Trello API to fetch the lists of a specific board.
/// It requires the user's API key, token, and the board's ID.
/// Returns a list of lists.
Future<List<dynamic>> getLists(
    String apiKey, String? token, String boardId) async {
  final response = await http.get(
    Uri.parse(
        'https://api.trello.com/1/boards/$boardId/lists?key=$apiKey&token=$token'),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load lists');
  }
}

Future<void> updateList(
    String apiKey, String? token, String listId, TrelloList list) async {
  final response = await http.put(
    Uri.parse(
        'https://api.trello.com/1/lists/$listId?key=$apiKey&token=$token&name=${list.name}'),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to update list');
  }
}

/// Fetches the cards of a specific list from Trello.
///
/// This function calls the Trello API to fetch the cards of a specific list.
/// It requires the user's API key, token, and the list's ID.
/// Returns a list of cards.
Future<List<dynamic>> getCards(
    String apiKey, String? token, String listId) async {
  final response = await http.get(
    Uri.parse(
        'https://api.trello.com/1/lists/$listId/cards?key=$apiKey&token=$token'),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load cards');
  }
}

/// Creates a new card in a specific list on Trello.
///
/// This function calls the Trello API to create a new card in a specific list.
/// It requires the user's API key, token, the list's ID, and the name of the card.
Future<void> createCard(
    String apiKey, String token, String listId, String name) async {
  final response = await http.post(
    Uri.parse(
        'https://api.trello.com/1/cards?key=$apiKey&token=$token&idList=$listId&name=$name'),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to create card');
  }
}

/// Deletes a specific card from Trello.
///
/// This function calls the Trello API to delete a specific card.
/// It requires the user's API key, token, and the card's ID.
Future<void> deleteCard(String apiKey, String? token, String cardId) async {
  final response = await http.delete(
    Uri.parse(
        'https://api.trello.com/1/cards/$cardId?key=$apiKey&token=$token'),
  );

  if (response.statusCode == 200) {
    Fluttertoast.showToast(
      msg: "Suppression effectuée",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  } else {
    throw Exception('Failed to delete card');
  }
}

/// Updates the name of a specific card on Trello.
///
/// This function calls the Trello API to update the name of a specific card.
/// It requires the user's API key, token, the card's ID, and the new name of the card.
Future<void> updateCard(
    String apiKey, String token, String cardId, TrelloCard card) async {
  final response = await http.put(
    Uri.parse(
        'https://api.trello.com/1/cards/$cardId?key=$apiKey&token=$token&desc=${card.desc}&name=${card.name}'),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to update card');
  }
}

/// Moves a specific card to a different list on Trello.
///
/// This function calls the Trello API to move a specific card to a different list.
/// It requires the user's API key, token, the card's ID, and the ID of the list to move the card to.
Future<void> moveCard(
    String apiKey, String token, String cardId, String listId) async {
  final response = await http.put(
    Uri.parse(
        'https://api.trello.com/1/cards/$cardId?key=$apiKey&token=$token&idList=$listId'),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to move card');
  }
}

/// Creates a new workspace on Trello.
///
/// This function calls the Trello API to create a new workspace.
/// It requires the user's API key, token, and the name of the workspace.
Future<void> createWorkspace(String apiKey, String token, String name) async {
  final response = await http.post(
    Uri.parse(
        'https://api.trello.com/1/organizations?key=$apiKey&token=$token&displayName=$name'),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to create workspace');
  }
}

/// Deletes a specific workspace from Trello.
///
/// This function calls the Trello API to delete a specific workspace.
/// It requires the user's API key, token, and the workspace's ID.
Future<void> deleteWorkspace(
    String apiKey, String token, String workspaceId) async {
  final response = await http.delete(
    Uri.parse(
        'https://api.trello.com/1/organizations/$workspaceId?key=$apiKey&token=$token'),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to delete workspace');
  }
}

Future<bool> updateWorkspace(String apiKey, String? token, String workspaceId,
    TrelloOrganization organization) async {
  final response = await http.put(
    Uri.parse(
        'https://api.trello.com/1/organizations/$workspaceId?key=$apiKey&token=$token&displayName=${organization.displayName}&desc=${organization.description}'),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to update workspace');
  }

  return true;
}

/// Updates the name of a specific workspace on Trello.
///
/// This function calls the Trello API to update the name of a specific workspace.
/// It requires the user's API key, token, the workspace's ID, and the new name of the workspace.
Future<TrelloOrganization> getWorkspace(
    String apiKey, String? token, String workspaceId) async {
  final response = await http.get(
    Uri.parse(
        'https://api.trello.com/1/organizations/$workspaceId?key=$apiKey&token=$token'),
  );

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    return TrelloOrganization.fromJson(data);
  } else {
    throw Exception('Failed to load workspace');
  }
}

/// Fetches the templates of boards in the gallery from Trello.
///
/// This function calls the Trello API to fetch the templates of boards in the gallery.
/// It requires the user's API key and token.
/// Returns a list of board templates.
Future<List<TrelloBoardTemplate>> getBoardTemplates(
    String apiKey, String? token) async {
  final response = await http.get(
    Uri.parse(
        'https://api.trello.com/1/boards/templates/gallery?key=$apiKey&token=$token'),
  );

  if (response.statusCode == 200) {
    var boardTemplatesJson = jsonDecode(response.body) as List;
    return boardTemplatesJson
        .map((boardTemplate) => TrelloBoardTemplate.fromJson(boardTemplate))
        .toList();
  } else {
    throw Exception('Failed to load board templates');
  }
}
