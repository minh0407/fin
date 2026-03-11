<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="model.Order"%>
<%@page import="model.OrderDetail"%>
<%@page import="model.Product"%>
<%@page import="model.CartItem"%>
<%@page import="model.User"%>
<%
    User user      = (User) session.getAttribute("user");
    String context = request.getContextPath();

    Order order                        = (Order)        request.getAttribute("order");
    List<OrderDetail> details          = (List<OrderDetail>) request.getAttribute("details");
    Map<Integer, Product> productMap   = (Map<Integer, Product>) request.getAttribute("productMap");

    // cart count for header badge
    java.util.List<CartItem> cart = (java.util.List<CartItem>) session.getAttribute("cart");
    int cartCount = 0;
    if (cart != null) for (CartItem ci : cart) cartCount += ci.getQuantity();

    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");

    // Badge class theo trạng thái
    String statusClass;
    if (order != null) {
        switch (order.getStatus().toLowerCase()) {
            case "processing": statusClass = "badge-processing"; break;
            case "shipping":   statusClass = "badge-shipping";   break;
            case "delivered":  statusClass = "badge-delivered";  break;
            case "cancelled":  statusClass = "badge-cancelled";  break;
            default:           statusClass = "badge-pending";
        }
    } else {
        statusClass = "badge-pending";
    }
    String payClass = (order != null && "Paid".equalsIgnoreCase(order.getPaymentStatus()))
                     ? "badge-paid" : "badge-unpaid";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1.0">
    <title>Chi tiết đơn hàng #<%=order != null ? order.getId() : ""%> – HomeElectro</title>
    <style>
        *{box-sizing:border-box;margin:0;padding:0}
        body{background:#f0f0f0;font-family:'Segoe UI',system-ui,sans-serif;color:#222;font-size:14px}
        a{text-decoration:none;color:inherit}
        img{display:block;max-width:100%}
        :root{--red:#d0021b;--red2:#a80115;--red-bg:#fff0f0;--border:#e8e8e8;--text:#222;--text2:#555;--text3:#999;--radius:10px}
        .cnt{max-width:1200px;margin:0 auto;padding:0 16px}

        /* HEADER */
        #site-header{background:var(--red);position:sticky;top:0;z-index:999;box-shadow:0 2px 10px rgba(0,0,0,.25)}
        .hd-topbar{background:var(--red2);padding:4px 0;font-size:12px;color:rgba(255,255,255,.85)}
        .hd-topbar-inner{display:flex;justify-content:space-between;align-items:center}
        .hd-main{padding:10px 0}
        .hd-main-inner{display:flex;align-items:center;gap:14px}
        .hd-logo{background:#fff;border-radius:8px;padding:6px 14px;font-weight:900;font-size:19px;color:var(--red);letter-spacing:-.5px;flex-shrink:0}
        .hd-logo span{background:rgba(208,2,27,.12);border-radius:4px;padding:0 3px}
        .hd-search{flex:1;position:relative;min-width:0}
        .hd-search input{width:100%;padding:10px 48px 10px 16px;border-radius:8px;border:none;font-size:14px;font-family:inherit;outline:none}
        .hd-search button{position:absolute;right:0;top:0;bottom:0;width:44px;background:#111;border:none;border-radius:0 8px 8px 0;cursor:pointer;color:#fff;font-size:16px}
        .hd-icons{display:flex;gap:6px;flex-shrink:0}
        .hd-icon-btn{display:flex;flex-direction:column;align-items:center;gap:2px;color:#fff;padding:4px 10px;border-radius:6px;cursor:pointer;position:relative;white-space:nowrap}
        .hd-icon-btn:hover{background:rgba(255,255,255,.15)}
        .hd-icon-ico{font-size:20px;position:relative;line-height:1}
        .hd-icon-btn > span{font-size:11px;color:rgba(255,255,255,.9)}
        .hd-badge{position:absolute;top:-5px;right:-7px;background:#fff;color:var(--red);font-size:10px;font-weight:800;border-radius:50%;width:16px;height:16px;display:flex;align-items:center;justify-content:center}
        .hd-account{position:relative}
        .hd-dropdown{display:none;position:absolute;top:calc(100% + 10px);right:0;background:#fff;border-radius:10px;box-shadow:0 8px 28px rgba(0,0,0,.18);min-width:190px;padding:6px 0;z-index:1000}
        .hd-account:hover .hd-dropdown{display:block}
        .hd-dropdown a{display:block;padding:10px 16px;font-size:13px;color:#333}
        .hd-dropdown a:hover{background:#f5f5f5;color:var(--red)}
        .hd-dropdown hr{border:none;border-top:1px solid #f0f0f0;margin:4px 0}
        .hd-catnav{background:rgba(0,0,0,.18);border-top:1px solid rgba(255,255,255,.1);overflow-x:auto;scrollbar-width:none}
        .hd-catnav::-webkit-scrollbar{display:none}
        .hd-catnav-inner{display:flex}
        .hd-catitem{padding:9px 15px;color:rgba(255,255,255,.9);font-size:13px;font-weight:500;white-space:nowrap;border-bottom:2px solid transparent;transition:all .15s}
        .hd-catitem:hover,.hd-catitem.on{color:#fff;border-bottom-color:#fff;background:rgba(255,255,255,.12)}

        /* PAGE */
        .page-main{padding:16px 0 40px}
        .section{background:#fff;border-radius:var(--radius);padding:18px 20px;margin-bottom:14px;border:1px solid var(--border)}
        .sec-hd{display:flex;align-items:center;justify-content:space-between;margin-bottom:16px}
        .sec-title{font-size:18px;font-weight:800;color:var(--text);display:flex;align-items:center;gap:8px}

        /* BREADCRUMB */
        .breadcrumb-bar{display:flex;align-items:center;gap:6px;font-size:13px;color:var(--text3);margin-bottom:16px}
        .breadcrumb-bar a{color:var(--text3)}
        .breadcrumb-bar a:hover{color:var(--red)}
        .breadcrumb-bar .sep{color:#ccc}
        .breadcrumb-bar .current{color:var(--text);font-weight:600}

        /* STATUS BADGES */
        .badge{display:inline-block;padding:3px 10px;border-radius:20px;font-size:11px;font-weight:700;white-space:nowrap}
        .badge-pending   {background:#fef3c7;color:#92400e}
        .badge-processing{background:#dbeafe;color:#1e40af}
        .badge-shipping  {background:#e0f2fe;color:#0369a1}
        .badge-delivered {background:#dcfce7;color:#166534}
        .badge-cancelled {background:#fee2e2;color:#991b1b}
        .badge-unpaid    {background:#fef9c3;color:#854d0e}
        .badge-paid      {background:#dcfce7;color:#166534}

        /* ORDER INFO META */
        .detail-meta{display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:10px;margin-bottom:20px}
        .meta-item{background:#f8faff;border-radius:8px;padding:10px 14px;border:1px solid #e0e7ff}
        .meta-label{font-size:11px;color:var(--text3);font-weight:600;text-transform:uppercase;letter-spacing:.5px;margin-bottom:4px}
        .meta-value{font-size:14px;font-weight:700;color:var(--text)}

        /* ITEMS TABLE */
        .items-table{width:100%;border-collapse:collapse}
        .items-table thead tr{background:#eff6ff}
        .items-table thead th{padding:11px 14px;font-size:12px;font-weight:700;color:#1e40af;text-align:left;white-space:nowrap}
        .items-table tbody tr{border-bottom:1px solid #e0e7ff;transition:background .15s}
        .items-table tbody tr:last-child{border-bottom:none}
        .items-table tbody tr:hover{background:#fafafa}
        .items-table td{padding:12px 14px;font-size:13px;vertical-align:middle}
        .product-thumb{width:52px;height:52px;object-fit:cover;border-radius:6px;border:1px solid var(--border)}
        .product-name{font-weight:600;color:var(--text);line-height:1.35}
        .product-id{font-size:11px;color:var(--text3)}
        .line-total{font-weight:800;color:#16a34a}

        /* SUMMARY */
        .summary-box{background:#f8faff;border-radius:8px;border:1.5px solid #dbeafe;padding:16px 20px;max-width:360px;margin-left:auto;margin-top:16px}
        .summary-row{display:flex;justify-content:space-between;align-items:center;padding:6px 0;font-size:13px;color:var(--text2)}
        .summary-row.divider{border-top:1px dashed #dbeafe;margin-top:6px;padding-top:10px}
        .summary-row.total{font-size:16px;font-weight:800;color:var(--red)}
        .summary-label{color:var(--text2)}

        /* STATUS TIMELINE */
        .timeline{display:flex;align-items:center;justify-content:center;gap:0;margin:20px 0 8px;overflow-x:auto;padding:4px 0}
        .tl-step{display:flex;flex-direction:column;align-items:center;gap:6px;min-width:80px}
        .tl-dot{width:32px;height:32px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:15px;border:2px solid #e0e7ff;background:#fff;transition:all .2s}
        .tl-dot.done{background:var(--red);border-color:var(--red);color:#fff}
        .tl-dot.active{background:#fff;border-color:var(--red);color:var(--red);box-shadow:0 0 0 4px rgba(208,2,27,.12)}
        .tl-label{font-size:10px;font-weight:600;color:var(--text3);text-align:center;white-space:nowrap}
        .tl-label.done{color:var(--red)}
        .tl-label.active{color:var(--text);font-weight:700}
        .tl-line{flex:1;height:2px;background:#e0e7ff;min-width:20px;max-width:60px}
        .tl-line.done{background:var(--red)}

        /* BACK BUTTON */
        .btn-back{display:inline-flex;align-items:center;gap:6px;padding:9px 20px;background:#fff;color:var(--red);border:1.5px solid var(--red);border-radius:8px;font-size:13px;font-weight:700;cursor:pointer;font-family:inherit;transition:all .15s}
        .btn-back:hover{background:var(--red);color:#fff}

        /* FOOTER */
        #site-footer{background:#111;color:#fff;padding:40px 0 0;margin-top:20px}
        .footer-grid{display:grid;grid-template-columns:2fr 1fr 1fr 1fr;gap:36px;padding-bottom:32px}
        .footer-logo{background:var(--red);border-radius:8px;padding:5px 14px;display:inline-block;font-weight:900;font-size:19px;color:#fff;margin-bottom:14px}
        .footer-about p{font-size:13px;color:#aaa;line-height:1.7;margin-bottom:14px}
        .footer-contact{display:flex;flex-direction:column;gap:6px;font-size:13px;color:#aaa}
        .footer-col-title{font-size:14px;font-weight:700;color:#fff;margin-bottom:14px}
        .footer-grid > div a{display:block;font-size:13px;color:#aaa;margin-bottom:8px}
        .footer-grid > div a:hover{color:#fff}
        .footer-bottom{border-top:1px solid #2a2a2a;padding:16px 0;display:flex;justify-content:space-between;font-size:12px;color:#666;flex-wrap:wrap;gap:8px}

        @media(max-width:768px){
            .detail-meta{grid-template-columns:1fr 1fr}
            .footer-grid{grid-template-columns:1fr 1fr}
            .timeline{justify-content:flex-start}
            .items-table thead th:nth-child(5),
            .items-table tbody td:nth-child(5){display:none}
        }
        @media(max-width:480px){
            .detail-meta{grid-template-columns:1fr}
            .footer-grid{grid-template-columns:1fr}
        }
    </style>
</head>
<body>

<!-- HEADER -->
<header id="site-header">
    <div class="hd-topbar">
        <div class="cnt">
            <div class="hd-topbar-inner">
                <span>🚚 Miễn phí giao hàng đơn từ 500.000đ &nbsp;|&nbsp; 📦 Đổi trả 30 ngày</span>
                <span>☎️ Hotline: <strong>1800 2097</strong></span>
            </div>
        </div>
    </div>
    <div class="hd-main">
        <div class="cnt">
            <div class="hd-main-inner">
                <a href="<%=context%>/home" class="hd-logo">Home<span>E</span></a>
                <form class="hd-search" action="<%=context%>/search" method="get">
                    <input type="text" name="keyword" placeholder="Tìm điện thoại, laptop, tai nghe...">
                    <button type="submit">🔍</button>
                </form>
                <div class="hd-icons">
                    <a href="<%=context%>/cart" class="hd-icon-btn">
                        <span class="hd-icon-ico">🛒
                            <% if (cartCount > 0) { %>
                            <span class="hd-badge"><%=cartCount%></span>
                            <% } %>
                        </span>
                        <span>Giỏ hàng</span>
                    </a>
                    <a href="<%=context%>/wishlist" class="hd-icon-btn">
                        <span class="hd-icon-ico">❤️</span>
                        <span>Yêu thích</span>
                    </a>
                    <div class="hd-account hd-icon-btn">
                        <span class="hd-icon-ico">👤</span>
                        <span>Tài khoản</span>
                        <div class="hd-dropdown">
                            <a href="<%=context%>/profile">👤 Tài khoản</a>
                            <a href="<%=context%>/orders">📦 Đơn hàng</a>
                            <hr>
                            <a href="<%=context%>/logout">🚪 Đăng xuất</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <nav class="hd-catnav">
        <div class="cnt">
            <div class="hd-catnav-inner">
                <a href="<%=context%>/products"              class="hd-catitem">Tất cả</a>
                <a href="<%=context%>/products?categoryId=1" class="hd-catitem">Tivi</a>
                <a href="<%=context%>/products?categoryId=2" class="hd-catitem">Tủ lạnh</a>
                <a href="<%=context%>/products?categoryId=3" class="hd-catitem">Máy giặt</a>
                <a href="<%=context%>/products?categoryId=4" class="hd-catitem">Máy lạnh</a>
                <a href="<%=context%>/products?categoryId=5" class="hd-catitem">Nhà bếp</a>
                <a href="<%=context%>/products?categoryId=6" class="hd-catitem">Gia dụng</a>
                <a href="<%=context%>/products?categoryId=7" class="hd-catitem">Phụ kiện</a>
            </div>
        </div>
    </nav>
</header>

<!-- MAIN -->
<main class="page-main">
    <div class="cnt">

        <!-- Breadcrumb -->
        <div class="breadcrumb-bar">
            <a href="<%=context%>/home">🏠 Trang chủ</a>
            <span class="sep">›</span>
            <a href="<%=context%>/orders">📦 Đơn hàng của tôi</a>
            <span class="sep">›</span>
            <span class="current">Chi tiết đơn #<%=order != null ? order.getId() : ""%></span>
        </div>

        <!-- Page heading -->
        <div class="section">
            <div class="sec-hd" style="margin-bottom:0">
                <div class="sec-title">
                    📋 Chi tiết đơn hàng
                    <span style="font-size:13px;font-weight:400;color:var(--text3)">#<%=order != null ? order.getId() : ""%></span>
                </div>
                <a href="<%=context%>/orders" class="btn-back">← Quay lại đơn hàng</a>
            </div>
        </div>

        <%-- ══ ORDER STATUS TIMELINE ══ --%>
        <% if (order != null) {
            String st = order.getStatus().toLowerCase();
            boolean isCancelled  = "cancelled".equals(st);
            boolean isPending    = true;
            boolean isProcessing = "processing".equals(st) || "shipping".equals(st) || "delivered".equals(st);
            boolean isShipping   = "shipping".equals(st)   || "delivered".equals(st);
            boolean isDelivered  = "delivered".equals(st);
        %>
        <div class="section">
            <% if (isCancelled) { %>
            <div style="text-align:center;padding:12px 0;color:#991b1b;font-weight:700;font-size:15px">
                ✖ Đơn hàng đã bị hủy
            </div>
            <% } else { %>
            <div class="timeline">
                <div class="tl-step">
                    <div class="tl-dot done">✓</div>
                    <div class="tl-label done">Đặt hàng</div>
                </div>
                <div class="tl-line <%=isProcessing ? "done" : ""%>"></div>
                <div class="tl-step">
                    <div class="tl-dot <%=isProcessing ? (isShipping ? "done" : "active") : ""%>">
                        <%=isProcessing && !isShipping ? "🔄" : (isShipping ? "✓" : "⏳")%>
                    </div>
                    <div class="tl-label <%=isProcessing ? (isShipping ? "done" : "active") : ""%>">Xử lý</div>
                </div>
                <div class="tl-line <%=isShipping ? "done" : ""%>"></div>
                <div class="tl-step">
                    <div class="tl-dot <%=isShipping ? (isDelivered ? "done" : "active") : ""%>">
                        <%=isShipping && !isDelivered ? "🚚" : (isDelivered ? "✓" : "🚚")%>
                    </div>
                    <div class="tl-label <%=isShipping ? (isDelivered ? "done" : "active") : ""%>">Giao hàng</div>
                </div>
                <div class="tl-line <%=isDelivered ? "done" : ""%>"></div>
                <div class="tl-step">
                    <div class="tl-dot <%=isDelivered ? "done" : ""%>">
                        <%=isDelivered ? "✓" : "📦"%>
                    </div>
                    <div class="tl-label <%=isDelivered ? "done" : ""%>">Đã nhận</div>
                </div>
            </div>
            <% } %>
        </div>

        <%-- ══ ORDER INFO ══ --%>
        <div class="section">
            <div style="margin-bottom:14px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px">
                <div style="font-size:15px;font-weight:800">Thông tin đơn hàng</div>
                <div style="display:flex;gap:8px;align-items:center">
                    <span class="badge <%=statusClass%>"><%=order.getStatus()%></span>
                    <span class="badge <%=payClass%>"><%=order.getPaymentStatus()%></span>
                </div>
            </div>
            <div class="detail-meta">
                <div class="meta-item">
                    <div class="meta-label">Mã đơn hàng</div>
                    <div class="meta-value" style="color:var(--red)">#<%=order.getId()%></div>
                </div>
                <div class="meta-item">
                    <div class="meta-label">Ngày đặt hàng</div>
                    <div class="meta-value"><%=order.getOrderDate() != null ? sdf.format(order.getOrderDate()) : "—"%></div>
                </div>
                <div class="meta-item">
                    <div class="meta-label">Người nhận</div>
                    <div class="meta-value"><%=order.getReceiverName()%></div>
                </div>
                <div class="meta-item">
                    <div class="meta-label">Số điện thoại</div>
                    <div class="meta-value"><%=order.getPhoneReceiver()%></div>
                </div>
                <div class="meta-item">
                    <div class="meta-label">Địa chỉ giao hàng</div>
                    <div class="meta-value" style="font-size:12px;font-weight:600"><%=order.getShippingAddress()%></div>
                </div>
                <div class="meta-item">
                    <div class="meta-label">Phương thức thanh toán</div>
                    <div class="meta-value"><%=order.getPaymentMethod()%></div>
                </div>
                <% if (order.getNote() != null && !order.getNote().trim().isEmpty()) { %>
                <div class="meta-item">
                    <div class="meta-label">Ghi chú</div>
                    <div class="meta-value" style="font-size:12px;font-weight:600"><%=order.getNote()%></div>
                </div>
                <% } %>
                <% if (order.getUpdatedDate() != null) { %>
                <div class="meta-item">
                    <div class="meta-label">Cập nhật lần cuối</div>
                    <div class="meta-value"><%=sdf.format(order.getUpdatedDate())%></div>
                </div>
                <% } %>
            </div>
        </div>

        <%-- ══ ORDER ITEMS ══ --%>
        <div class="section">
            <div style="font-size:15px;font-weight:800;margin-bottom:16px">Danh sách sản phẩm</div>
            <% if (details != null && !details.isEmpty()) {
                double subtotal = 0;
                double discountTotal = 0;
            %>
            <div style="overflow-x:auto">
                <table class="items-table">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Sản phẩm</th>
                            <th>Đơn giá</th>
                            <th>Số lượng</th>
                            <th>Giảm giá</th>
                            <th>Thành tiền</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% int idx = 1;
                           for (OrderDetail d : details) {
                               Product p    = productMap != null ? productMap.get(d.getProductId()) : null;
                               String pName = p != null ? p.getName() : "Sản phẩm #" + d.getProductId();
                               String pImg  = p != null ? p.getImage() : null;
                               double lineTotal = d.getPrice() * d.getQuantity() * (1 - d.getDiscount() / 100.0);
                               subtotal += d.getPrice() * d.getQuantity();
                               discountTotal += d.getPrice() * d.getQuantity() * (d.getDiscount() / 100.0);
                        %>
                        <tr>
                            <td style="color:var(--text3)"><%=idx++%></td>
                            <td>
                                <div style="display:flex;align-items:center;gap:10px">
                                    <% if (pImg != null && !pImg.isEmpty()) { %>
                                    <img src="<%=pImg%>" alt="<%=pName%>" class="product-thumb">
                                    <% } else { %>
                                    <div style="width:52px;height:52px;background:#f5f5f5;border-radius:6px;display:flex;align-items:center;justify-content:center;font-size:22px">📦</div>
                                    <% } %>
                                    <div>
                                        <div class="product-name"><%=pName%></div>
                                        <div class="product-id">SP #<%=d.getProductId()%></div>
                                    </div>
                                </div>
                            </td>
                            <td><%=String.format("%,.0f", d.getPrice())%>đ</td>
                            <td style="font-weight:700">x<%=d.getQuantity()%></td>
                            <td>
                                <% if (d.getDiscount() > 0) { %>
                                <span class="badge" style="background:#fef3c7;color:#92400e">-<%=String.format("%.0f", d.getDiscount())%>%</span>
                                <% } else { %>
                                <span style="color:var(--text3)">—</span>
                                <% } %>
                            </td>
                            <td class="line-total"><%=String.format("%,.0f", lineTotal)%>đ</td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

            <!-- Summary -->
            <div class="summary-box">
                <div class="summary-row">
                    <span class="summary-label">Tạm tính</span>
                    <span><%=String.format("%,.0f", subtotal)%>đ</span>
                </div>
                <% if (discountTotal > 0) { %>
                <div class="summary-row">
                    <span class="summary-label">Giảm giá sản phẩm</span>
                    <span style="color:#16a34a">-<%=String.format("%,.0f", discountTotal)%>đ</span>
                </div>
                <% } %>
                <% if (order.getDiscountAmount() > 0) { %>
                <div class="summary-row">
                    <span class="summary-label">Mã giảm giá</span>
                    <span style="color:#16a34a">-<%=String.format("%,.0f", order.getDiscountAmount())%>đ</span>
                </div>
                <% } %>
                <div class="summary-row divider total">
                    <span>Tổng thanh toán</span>
                    <span><%=String.format("%,.0f", order.getTotalAmount())%>đ</span>
                </div>
            </div>
            <% } else { %>
            <div style="text-align:center;padding:32px;color:var(--text3)">
                <div style="font-size:40px;margin-bottom:10px">📭</div>
                <div>Không có sản phẩm nào trong đơn hàng này.</div>
            </div>
            <% } %>
        </div>

        <!-- Back button -->
        <div style="text-align:center;margin-top:8px">
            <a href="<%=context%>/orders" class="btn-back">← Quay lại danh sách đơn hàng</a>
        </div>

        <% } %>

    </div>
</main>

<!-- FOOTER -->
<footer id="site-footer">
    <div class="cnt">
        <div class="footer-grid">
            <div class="footer-about">
                <div class="footer-logo">HomeE</div>
                <p>Hệ thống điện máy chính hãng với hơn 200 showroom trên toàn quốc. Cam kết giá tốt, bảo hành đầy đủ.</p>
                <div class="footer-contact">
                    <span>📞 Hotline: 1800 2097 (miễn phí)</span>
                    <span>✉️ support@homeelectro.vn</span>
                    <span>🕐 8:00 – 22:00 tất cả các ngày</span>
                </div>
            </div>
            <div>
                <div class="footer-col-title">Sản phẩm</div>
                <a href="<%=context%>/products?categoryId=1">Tivi</a>
                <a href="<%=context%>/products?categoryId=2">Tủ lạnh</a>
                <a href="<%=context%>/products?categoryId=3">Máy giặt</a>
                <a href="<%=context%>/products?categoryId=4">Máy lạnh</a>
                <a href="<%=context%>/products?categoryId=5">Nhà bếp</a>
            </div>
            <div>
                <div class="footer-col-title">Hỗ trợ</div>
                <a href="#">Hướng dẫn mua hàng</a>
                <a href="#">Chính sách đổi trả</a>
                <a href="#">Tra cứu bảo hành</a>
                <a href="#">Thanh toán trả góp</a>
                <a href="#">Liên hệ chúng tôi</a>
            </div>
            <div>
                <div class="footer-col-title">Về chúng tôi</div>
                <a href="#">Giới thiệu</a>
                <a href="#">Tuyển dụng</a>
                <a href="#">Tin tức</a>
                <a href="#">Hệ thống cửa hàng</a>
                <a href="#">Chính sách bảo mật</a>
            </div>
        </div>
        <div class="footer-bottom">
            <span>© 2025 HomeElectro. All rights reserved.</span>
            <span>Được xây dựng với ❤️ tại Việt Nam</span>
        </div>
    </div>
</footer>

</body>
</html>
