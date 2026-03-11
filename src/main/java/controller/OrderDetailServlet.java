package controller;

import dao.OrderDAO;
import dao.OrderDetailDAO;
import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Order;
import model.OrderDetail;
import model.Product;
import model.User;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/orderDetail")
public class OrderDetailServlet extends HttpServlet {

    private final OrderDAO       orderDAO       = new OrderDAO();
    private final OrderDetailDAO orderDetailDAO = new OrderDetailDAO();
    private final ProductDAO     productDAO     = new ProductDAO();

    /** GET /orderDetail?orderId=X — hiển thị chi tiết một đơn hàng */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // Chưa đăng nhập → về trang login
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");

        // Admin → chuyển về trang quản lý đơn hàng admin
        if ("admin".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/admin/orders");
            return;
        }

        // Lấy orderId từ request parameter
        String orderIdParam = request.getParameter("orderId");
        if (orderIdParam == null || orderIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/orders");
            return;
        }

        int orderId;
        try {
            orderId = Integer.parseInt(orderIdParam);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/orders");
            return;
        }

        // Lấy thông tin đơn hàng
        Order order = orderDAO.getOrderById(orderId);

        // Kiểm tra đơn hàng tồn tại và thuộc về user hiện tại
        if (order == null || order.getUserId() != user.getId()) {
            response.sendRedirect(request.getContextPath() + "/orders");
            return;
        }

        // Lấy danh sách sản phẩm trong đơn hàng
        List<OrderDetail> details = orderDetailDAO.getDetailsByOrderId(orderId);

        // Lấy thông tin sản phẩm cho từng dòng đơn hàng
        Map<Integer, Product> productMap = new HashMap<>();
        for (OrderDetail d : details) {
            int pid = d.getProductId();
            if (!productMap.containsKey(pid)) {
                Product p = productDAO.getById(pid);
                if (p != null) {
                    productMap.put(pid, p);
                }
            }
        }

        request.setAttribute("order",      order);
        request.setAttribute("details",    details);
        request.setAttribute("productMap", productMap);

        request.getRequestDispatcher("/orderDetail.jsp").forward(request, response);
    }
}
