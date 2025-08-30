<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>ConnectHub | Login</title>
    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">
    <!-- Font Awesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #4361ee;
            --secondary: #3a0ca3;
            --accent: #4895ef;
            --light: #f8f9fa;
            --dark: #212529;
            --success: #4cc9f0;
            --text: #495057;
            --shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
        }
        
        body {
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            font-family: 'Poppins', sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            padding: 20px;
        }
        
        .login-container {
            display: flex;
            max-width: 1000px;
            width: 100%;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: var(--shadow);
        }
        
        .login-illustration {
            flex: 1;
            background: linear-gradient(to right, var(--primary), var(--secondary));
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            padding: 40px;
            color: white;
            text-align: center;
        }
        
        .login-illustration img {
            max-width: 80%;
            margin-bottom: 30px;
        }
        
        .login-illustration h2 {
            font-weight: 600;
            margin-bottom: 15px;
        }
        
        .login-illustration p {
            opacity: 0.9;
            font-weight: 300;
        }
        
        .login-card {
            flex: 1;
            padding: 50px;
            background-color: white;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }
        
        .login-card h2 {
            color: var(--secondary);
            font-weight: 600;
            margin-bottom: 30px;
            text-align: center;
        }
        
        .form-group {
            margin-bottom: 20px;
            position: relative;
        }
        
        .form-control {
            height: 50px;
            border-radius: 8px;
            border: 1px solid #e0e0e0;
            padding-left: 45px;
            font-size: 15px;
            transition: all 0.3s;
        }
        
        .form-control:focus {
            border-color: var(--accent);
            box-shadow: 0 0 0 0.2rem rgba(67, 97, 238, 0.25);
        }
        
        .input-icon {
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--text);
            opacity: 0.6;
        }
        
        .btn-login {
            background: linear-gradient(to right, var(--primary), var(--secondary));
            border: none;
            height: 50px;
            border-radius: 8px;
            font-weight: 500;
            font-size: 16px;
            letter-spacing: 0.5px;
            margin-top: 10px;
            transition: all 0.3s;
        }
        
        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(67, 97, 238, 0.3);
        }
        
        .divider {
            display: flex;
            align-items: center;
            margin: 25px 0;
            color: #adb5bd;
            font-size: 14px;
        }
        
        .divider::before, .divider::after {
            content: "";
            flex: 1;
            border-bottom: 1px solid #e0e0e0;
        }
        
        .divider::before {
            margin-right: 10px;
        }
        
        .divider::after {
            margin-left: 10px;
        }
        
        .social-login {
            display: flex;
            justify-content: center;
            gap: 15px;
            margin-bottom: 25px;
        }
        
        .social-btn {
            width: 45px;
            height: 45px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 18px;
            transition: all 0.3s;
        }
        
        .social-btn:hover {
            transform: translateY(-3px);
        }
        
        .facebook {
            background-color: #3b5998;
        }
        
        .google {
            background-color: #db4437;
        }
        
        .twitter {
            background-color: #1da1f2;
        }
        
        .register-link {
            text-align: center;
            margin-top: 20px;
            color: var(--text);
        }
        
        .register-link a {
            color: var(--primary);
            font-weight: 500;
            text-decoration: none;
            transition: all 0.3s;
        }
        
        .register-link a:hover {
            color: var(--secondary);
            text-decoration: underline;
        }
        
        .forgot-password {
            text-align: right;
            margin-top: -15px;
            margin-bottom: 20px;
        }
        
        .forgot-password a {
            color: var(--text);
            font-size: 13px;
            text-decoration: none;
            transition: all 0.3s;
        }
        
        .forgot-password a:hover {
            color: var(--primary);
        }
        
        @media (max-width: 768px) {
            .login-container {
                flex-direction: column;
            }
            
            .login-illustration {
                display: none;
            }
            
            .login-card {
                padding: 30px;
            }
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="login-illustration">
            <img src="https://cdn-icons-png.flaticon.com/512/4787/4787427.png" alt="Social Media Illustration">
            <h2>Welcome to ConnectHub</h2>
            <p>Connect with friends and the world around you on ConnectHub.</p>
        </div>
        
        <div class="login-card">
            <h2>Sign In</h2>
            
            <form action="login" method="POST">
                <!-- Username/Email Field -->
                <div class="form-group">
                    <i class="fas fa-user input-icon"></i>
                    <input type="text" class="form-control" id="username" name="username" placeholder="Username or Email" required>
                </div>

                <!-- Password Field -->
                <div class="form-group">
                    <i class="fas fa-lock input-icon"></i>
                    <input type="password" class="form-control" id="password" name="password" placeholder="Password" required>
                </div>
                
                <div class="forgot-password">
                    <a href="forgot-password.jsp">Forgot password?</a>
                </div>

                <!-- Login Button -->
                <button type="submit" class="btn btn-primary btn-login">
                    <i class="fas fa-sign-in-alt mr-2"></i> Login
                </button>
            </form>
            
            <div class="divider">or continue with</div>
            
            <div class="social-login">
                <a href="#" class="social-btn facebook"><i class="fab fa-facebook-f"></i></a>
                <a href="#" class="social-btn google"><i class="fab fa-google"></i></a>
                <a href="#" class="social-btn twitter"><i class="fab fa-twitter"></i></a>
            </div>
            
            <div class="register-link">
                Don't have an account? <a href="registration.jsp">Create one</a>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS and dependencies -->
    <script src="https://cdn.jsdelivr.net/npm/jquery@3.5.1/dist/jquery.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.min.js"></script>
</body>
</html>