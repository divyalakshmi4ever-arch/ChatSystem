<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String currentUser = (String) session.getAttribute("username");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Chat System</title>
    <style>
        * { box-sizing: border-box; }
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #f2f4f8;
        }
        .header {
            height: 65px;
            background: #667eea;
            color: white;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 25px;
        }
        .header h2 { margin: 0; }
        .user { font-size: 14px; }
        .container {
            max-width: 900px;
            margin: 25px auto;
            background: white;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 5px 20px rgba(0,0,0,.12);
        }
        .top {
            padding: 18px;
            border-bottom: 1px solid #ddd;
        }
        select {
            padding: 10px;
            width: 250px;
            border-radius: 7px;
            border: 1px solid #ccc;
        }
        #messages {
            height: 480px;
            overflow-y: auto;
            padding: 20px;
            background: #f8f9fc;
        }
        .message {
            max-width: 70%;
            padding: 12px 15px;
            margin: 10px 0;
            border-radius: 12px;
            clear: both;
        }
        .mine {
            float: right;
            background: #667eea;
            color: white;
        }
        .theirs {
            float: left;
            background: white;
            border: 1px solid #ddd;
        }
        .meta {
            font-size: 11px;
            opacity: .75;
            margin-bottom: 5px;
        }
        .text {
            word-wrap: break-word;
            white-space: pre-wrap;
        }
        .send-area {
            display: flex;
            gap: 10px;
            padding: 15px;
            border-top: 1px solid #ddd;
        }
        #messageInput {
            flex: 1;
            padding: 13px;
            border: 1px solid #ccc;
            border-radius: 8px;
            font-size: 15px;
        }
        #sendBtn {
            width: 100px;
            border: none;
            border-radius: 8px;
            background: #667eea;
            color: white;
            cursor: pointer;
        }
        #sendBtn:hover { background: #5568d8; }
        .empty {
            text-align: center;
            color: #888;
            margin-top: 180px;
        }
    </style>
</head>
<body>

<div class="header">
    <h2>💬 Chat System</h2>
    <div class="user">Logged in as: <b><%= currentUser %></b></div>
</div>

<div class="container">
    <div class="top">
        <label><b>Chat with:</b></label>
        <select id="receiver">
            <option value="">-- Select User --</option>
        </select>
    </div>

    <div id="messages">
        <div class="empty">Select a user to start chatting</div>
    </div>

    <div class="send-area">
        <input id="messageInput" type="text" placeholder="Type your message..." disabled>
        <button id="sendBtn" disabled>Send</button>
    </div>
</div>

<script>
const currentUser = "<%= currentUser %>";
const receiverSelect = document.getElementById("receiver");
const messageInput = document.getElementById("messageInput");
const sendBtn = document.getElementById("sendBtn");
const messagesDiv = document.getElementById("messages");

async function loadUsers() {
    try {
        const response = await fetch("users");
        const users = await response.json();

        users.forEach(user => {
            const option = document.createElement("option");
            option.value = user;
            option.textContent = user;
            receiverSelect.appendChild(option);
        });
    } catch (error) {
        console.error(error);
    }
}

async function loadMessages() {
    const receiver = receiverSelect.value;

    if (!receiver) {
        messagesDiv.innerHTML =
            '<div class="empty">Select a user to start chatting</div>';
        return;
    }

    try {
        const response = await fetch(
            "chat?receiver=" + encodeURIComponent(receiver)
        );

        const messages = await response.json();

        messagesDiv.innerHTML = "";

        if (messages.length === 0) {
            messagesDiv.innerHTML =
                '<div class="empty">No messages yet. Say hello! 👋</div>';
            return;
        }

        messages.forEach(msg => {
            const box = document.createElement("div");
            box.className =
                "message " + (msg.sender === currentUser ? "mine" : "theirs");

            const meta = document.createElement("div");
            meta.className = "meta";
            meta.textContent = msg.sender + " → " + msg.receiver + " | " + msg.time;

            const text = document.createElement("div");
            text.className = "text";
            text.textContent = msg.message;

            box.appendChild(meta);
            box.appendChild(text);
            messagesDiv.appendChild(box);
        });

        messagesDiv.scrollTop = messagesDiv.scrollHeight;

    } catch (error) {
        console.error(error);
    }
}

async function sendMessage() {
    const receiver = receiverSelect.value;
    const message = messageInput.value.trim();

    if (!receiver || !message) return;

    const formData = new URLSearchParams();
    formData.append("receiver", receiver);
    formData.append("message", message);

    try {
        const response = await fetch("chat", {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded"
            },
            body: formData
        });

        const result = await response.json();

        if (result.success) {
            messageInput.value = "";
            await loadMessages();
            messageInput.focus();
        } else {
            alert(result.error || "Message not sent");
        }
    } catch (error) {
        alert("Server error");
        console.error(error);
    }
}

receiverSelect.addEventListener("change", () => {
    const selected = receiverSelect.value;
    messageInput.disabled = !selected;
    sendBtn.disabled = !selected;

    loadMessages();
});

sendBtn.addEventListener("click", sendMessage);

messageInput.addEventListener("keydown", event => {
    if (event.key === "Enter") {
        sendMessage();
    }
});

loadUsers();

// AJAX automatically refreshes chat messages every 2 seconds.
setInterval(() => {
    if (receiverSelect.value) {
        loadMessages();
    }
}, 2000);
</script>

</body>
</html>
