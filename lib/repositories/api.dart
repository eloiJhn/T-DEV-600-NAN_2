import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:trelltech/models/board.dart';

/**
 * Fetches the user's ID from Trello.
 *
 * This method calls the Trello API to fetch the user's ID.
 * It requires the user's API key and token.
 * Returns the user's ID.
 */
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

/**
 * Fetches the user's boards from Trello.
 *
 * This method calls the Trello API to fetch the user's boards.
 * It requires the user's API key and token.
 * Returns a list of boards.
 */
Future<List<Board>> getBoards(String apiKey, String token, String workspaceId) async {
  final response = await http.get(
    Uri.parse('https://api.trello.com/1/organizations/$workspaceId/boards?key=$apiKey&token=$token'),
  );

  if (response.statusCode == 200) {
    var boardsJson = jsonDecode(response.body) as List;
    return boardsJson.map((board) => Board.fromJson(board)).toList();
  } else {
    throw Exception('Failed to load boards');
  }
}

Future<List<dynamic>> getWorkspace(String apiKey, String? token,String? clientId) async {
  final response = await http.get(
    Uri.parse('https://api.trello.com/1/members/$clientId/organizations?key=$apiKey&token=$token'),
  );

  if (response.statusCode == 200) {
    print(response.body);
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load workspace');
  }
}

/**
 * Fetches the lists of a specific board from Trello.
 *
 * This method calls the Trello API to fetch the lists of a specific board.
 * It requires the user's API key, token, and the board's ID.
 * Returns a list of lists.
 */
Future<List<dynamic>> getLists(String apiKey, String token, String boardId) async {
  final response = await http.get(
    Uri.parse('https://api.trello.com/1/boards/$boardId/lists?key=$apiKey&token=$token'),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load lists');
  }
}

/**
 * Fetches the cards of a specific list from Trello.
 *
 * This method calls the Trello API to fetch the cards of a specific list.
 * It requires the user's API key, token, and the list's ID.
 * Returns a list of cards.
 */
Future<List<dynamic>> getCards(String apiKey, String token, String listId) async {
  final response = await http.get(
    Uri.parse('https://api.trello.com/1/lists/$listId/cards?key=$apiKey&token=$token'),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load cards');
  }
}

/**
 * Creates a new card in a specific list on Trello.
 *
 * This method calls the Trello API to create a new card in a specific list.
 * It requires the user's API key, token, the list's ID, and the name of the card.
 */
Future<void> createCard(String apiKey, String token, String listId, String name) async {
  final response = await http.post(
    Uri.parse('https://api.trello.com/1/cards?key=$apiKey&token=$token&idList=$listId&name=$name'),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to create card');
  }
}

/**
 * Deletes a specific card from Trello.
 *
 * This method calls the Trello API to delete a specific card.
 * It requires the user's API key, token, and the card's ID.
 */
Future<void> deleteCard(String apiKey, String token, String cardId) async {
  final response = await http.delete(
    Uri.parse('https://api.trello.com/1/cards/$cardId?key=$apiKey&token=$token'),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to delete card');
  }
}

/**
 * Updates the name of a specific card on Trello.
 *
 * This method calls the Trello API to update the name of a specific card.
 * It requires the user's API key, token, the card's ID, and the new name of the card.
 */
Future<void> updateCard(String apiKey, String token, String cardId, String name) async {
  final response = await http.put(
    Uri.parse('https://api.trello.com/1/cards/$cardId?key=$apiKey&token=$token&name=$name'),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to update card');
  }
}

/**
 * Moves a specific card to a different list on Trello.
 *
 * This method calls the Trello API to move a specific card to a different list.
 * It requires the user's API key, token, the card's ID, and the ID of the list to move the card to.
 */
Future<void> moveCard(String apiKey, String token, String cardId, String listId) async {
  final response = await http.put(
    Uri.parse('https://api.trello.com/1/cards/$cardId?key=$apiKey&token=$token&idList=$listId'),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to move card');
  }
}

/**
 * Creates a new workspace on Trello.
 *
 * This method calls the Trello API to create a new workspace.
 * It requires the user's API key, token, and the name of the workspace.
 */
Future<void> createWorkspace(String apiKey, String token, String name) async {
  final response = await http.post(
    Uri.parse('https://api.trello.com/1/organizations?key=$apiKey&token=$token&displayName=$name'),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to create workspace');
  }
}

/**
 * Deletes a specific workspace from Trello.
 *
 * This method calls the Trello API to delete a specific workspace.
 * It requires the user's API key, token, and the workspace's ID.
 */
Future<void> deleteWorkspace(String apiKey, String token, String workspaceId) async {
  final response = await http.delete(
    Uri.parse('https://api.trello.com/1/organizations/$workspaceId?key=$apiKey&token=$token'),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to delete workspace');
  }
}

/**
 * Updates the name of a specific workspace on Trello.
 *
 * This method calls the Trello API to update the name of a specific workspace.
 * It requires the user's API key, token, the workspace's ID, and the new name of the workspace.
 */
Future<void> updateWorkspace(String apiKey, String token, String workspaceId, String name) async {
  final response = await http.put(
    Uri.parse('https://api.trello.com/1/organizations/$workspaceId?key=$apiKey&token=$token&displayName=$name'),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to update workspace');
  }
}
