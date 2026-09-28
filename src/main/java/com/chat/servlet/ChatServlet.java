package com.chat.servlet;

import com.chat.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/chat")
public class ChatServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json;charset=UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().print("{\"error\":\"Please login\"}");
            return;
        }

        String sender = (String) session.getAttribute("username");
        String receiver = request.getParameter("receiver");

        if (receiver == null || receiver.trim().isEmpty()) {
            response.getWriter().print("[]");
            return;
        }

        String sql = """
            SELECT sender, receiver, message,
                   DATE_FORMAT(message_time, '%Y-%m-%d %H:%i:%s') AS message_time
            FROM messages
            WHERE (sender = ? AND receiver = ?)
               OR (sender = ? AND receiver = ?)
            ORDER BY message_time ASC, id ASC
            """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             PrintWriter out = response.getWriter()) {

            ps.setString(1, sender);
            ps.setString(2, receiver);
            ps.setString(3, receiver);
            ps.setString(4, sender);

            try (ResultSet rs = ps.executeQuery()) {
                StringBuilder json = new StringBuilder("[");
                boolean first = true;

                while (rs.next()) {
                    if (!first) json.append(",");
                    first = false;

                    json.append("{")
                        .append("\"sender\":\"").append(jsonEscape(rs.getString("sender"))).append("\",")
                        .append("\"receiver\":\"").append(jsonEscape(rs.getString("receiver"))).append("\",")
                        .append("\"message\":\"").append(jsonEscape(rs.getString("message"))).append("\",")
                        .append("\"time\":\"").append(jsonEscape(rs.getString("message_time"))).append("\"")
                        .append("}");
                }

                json.append("]");
                out.print(json);
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().print("{\"error\":\"Unable to load messages\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json;charset=UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().print("{\"success\":false,\"error\":\"Please login\"}");
            return;
        }

        String sender = (String) session.getAttribute("username");
        String receiver = request.getParameter("receiver");
        String message = request.getParameter("message");

        if (receiver == null || receiver.trim().isEmpty()
                || message == null || message.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().print("{\"success\":false,\"error\":\"Receiver and message are required\"}");
            return;
        }

        String sql = "INSERT INTO messages(sender, receiver, message) VALUES (?, ?, ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, sender);
            ps.setString(2, receiver.trim());
            ps.setString(3, message.trim());
            ps.executeUpdate();

            response.getWriter().print("{\"success\":true}");

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().print("{\"success\":false,\"error\":\"Message could not be sent\"}");
        }
    }

    private static String jsonEscape(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "\\r")
                .replace("\n", "\\n");
    }
}
