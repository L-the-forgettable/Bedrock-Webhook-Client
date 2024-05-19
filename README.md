# Bedrock-Webhook-Server
A bedrock edition webhook server written the godot engine

Currently has minimal functionality;
   - Displaying connected clients' usernames
   - A chat thread, relaying messages sent to other connected clients
   - A display for messages sent in the chat thread
   - A chatbox for the server to send its own messages to all the clients

Planned features:
   - A player map for displaying connected player's positions
   - GUI-less addon version for use in other projects

Due to limitations of the webhook system in minecraft, most events pertaining to other players (such as chat messages) will not be received

# Additional credits
UUID Generator: [Minos UUID Generator](https://godotengine.org/asset-library/asset/2658) By Minoqi [(Github Repo)](https://github.com/Minoqi/minos-UUID-generator-for-godot) <br>
Websocket Server: [NodeWebSockets](https://godotengine.org/asset-library/asset/2360) By IcterusGames [(Github page)](https://github.com/IcterusGames/NodeWebSockets)
