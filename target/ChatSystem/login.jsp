<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Chat System - Login</title>
    <style>
        * { box-sizing: border-box; }
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea, #764ba2);
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .login-box {
            width: 360px;
            background: white;
            padding: 35px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,.25);
        }
        h2 { text-align: center; margin-bottom: 25px; }
        input {
            width: 100%;
            padding: 13px;
            border: 1px solid #ccc;
            border-radius: 8px;
            margin: 10px 0;
            font-size: 15px;
        }
        button {
            width: 100%;
            padding: 13px;
            border: none;
            border-radius: 8px;
            background: #667eea;
            color: white;
            font-size: 16px;
            cursor: pointer;
            margin-top: 10px;
        }
        button:hover { background: #5568d8; }
        .error {
            color: #d00;
            text-align: center;
            margin-top: 15px;
        }
        .hint {
            text-align: center;
            color: #666;
            font-size: 13px;
            margin-top: 15px;
        }
    </style>
</head>
<body>
<div class="login-box">
    <h2>💬 Chat System</h2>

    <form action="login" method="post">
        <input type="text" name="username" placeholder="Enter username" required>
        <button type="submit">Login</button>
    </form>

    <div class="hint">Try: divya or arun</div>

    <%
        String error = request.getParameter("error");
        if (error != null) {
    %>
        <div class="error"><%= error.replace("+", " ") %></div>
    <%
        }
    %>
</div>
</body>
</html>
