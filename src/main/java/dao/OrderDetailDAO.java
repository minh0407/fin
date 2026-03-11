package dao;

import model.OrderDetail;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderDetailDAO extends DBContext {

    // ── INSERT ────────────────────────────────────────────────────────────
    public boolean insertOrderDetail(OrderDetail d) {
        String sql = "INSERT INTO order_details (order_id, product_id, quantity, price, discount) "
                   + "VALUES (?, ?, ?, ?, ?)";
        try (Connection cn = getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt   (1, d.getOrderId());
            ps.setInt   (2, d.getProductId());
            ps.setInt   (3, d.getQuantity());
            ps.setDouble(4, d.getPrice());
            ps.setDouble(5, d.getDiscount());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ── SELECT BY ORDER ───────────────────────────────────────────────────
    public List<OrderDetail> getDetailsByOrderId(int orderId) {
        List<OrderDetail> list = new ArrayList<>();
        String sql = "SELECT order_id, product_id, quantity, price, discount "
                   + "FROM order_details WHERE order_id = ?";
        try (Connection cn = getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new OrderDetail(
                        rs.getInt   ("order_id"),
                        rs.getInt   ("product_id"),
                        rs.getInt   ("quantity"),
                        rs.getDouble("price"),
                        rs.getDouble("discount")
                    ));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
