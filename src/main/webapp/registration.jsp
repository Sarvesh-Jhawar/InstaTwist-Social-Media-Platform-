<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>ConnectHub | Register</title>
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
            --error: #e63946;
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
        
        .register-container {
            display: flex;
            max-width: 1000px;
            width: 100%;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: var(--shadow);
        }
        
        .register-illustration {
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
        
        .register-illustration img {
            max-width: 80%;
            margin-bottom: 30px;
        }
        
        .register-illustration h2 {
            font-weight: 600;
            margin-bottom: 15px;
        }
        
        .register-illustration p {
            opacity: 0.9;
            font-weight: 300;
        }
        
        .register-card {
            flex: 1;
            padding: 50px;
            background-color: white;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }
        
        .register-card h2 {
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
        
        .btn-register {
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
        
        .btn-register:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(67, 97, 238, 0.3);
        }
        
        .login-link {
            text-align: center;
            margin-top: 20px;
            color: var(--text);
        }
        
        .login-link a {
            color: var(--primary);
            font-weight: 500;
            text-decoration: none;
            transition: all 0.3s;
        }
        
        .login-link a:hover {
            color: var(--secondary);
            text-decoration: underline;
        }
        
        .alert-danger {
            background-color: rgba(230, 57, 70, 0.1);
            color: var(--error);
            border: 1px solid rgba(230, 57, 70, 0.3);
            border-radius: 8px;
            padding: 12px 15px;
            margin-bottom: 20px;
            font-size: 14px;
        }
        
        .password-strength {
            height: 4px;
            background: #e0e0e0;
            border-radius: 2px;
            margin-top: 5px;
            overflow: hidden;
        }
        
        .strength-meter {
            height: 100%;
            width: 0;
            transition: width 0.3s;
        }
        
        .weak {
            background: #e63946;
            width: 33%;
        }
        
        .medium {
            background: #f4a261;
            width: 66%;
        }
        
        .strong {
            background: #2a9d8f;
            width: 100%;
        }
        
        .password-hint {
            font-size: 12px;
            color: #6c757d;
            margin-top: 5px;
        }
        
        @media (max-width: 768px) {
            .register-container {
                flex-direction: column;
            }
            
            .register-illustration {
                display: none;
            }
            
            .register-card {
                padding: 30px;
            }
        }
    </style>
</head>
<body>
    <div class="register-container">
        <div class="register-illustration">
            <img src="https://cdn-icons-png.flaticon.com/512/4787/4787427.png" alt="Social Media Illustration">
            <h2>Join ConnectHub Today</h2>
            <p>Be part of our growing community and connect with people around the world.</p>
        </div>
        
        <div class="register-card">
            <h2>Create Account</h2>
            
            <% if (request.getParameter("error") != null) { %>
                <div class="alert alert-danger">
                    <i class="fas fa-exclamation-circle mr-2"></i> Registration failed. Please try again.
                </div>
            <% } %>

            <form action="register" method="POST">
                <div class="form-group">
                    <i class="fas fa-user input-icon"></i>
                    <input type="text" class="form-control" id="username" name="username" placeholder="Username" required>
                </div>
                
                <div class="form-group">
                    <i class="fas fa-envelope input-icon"></i>
                    <input type="email" class="form-control" id="email" name="email" placeholder="Email address" required>
                </div>
                
                <div class="form-group">
                    <i class="fas fa-lock input-icon"></i>
                    <input type="password" class="form-control" id="password" name="password" placeholder="Create password" required
                           oninput="checkPasswordStrength(this.value)">
                    <div class="password-strength">
                        <div class="strength-meter" id="password-strength-meter"></div>
                    </div>
                    <div class="password-hint">
                        Use 8+ characters with a mix of letters, numbers & symbols
                    </div>
                </div>
                
                <button type="submit" class="btn btn-primary btn-register">
                    <i class="fas fa-user-plus mr-2"></i> Create Account
                </button>
            </form>

            <div class="login-link">
                Already have an account? <a href="login.jsp">Sign in</a>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS and dependencies -->
    <script src="https://cdn.jsdelivr.net/npm/jquery@3.5.1/dist/jquery.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.min.js"></script>
    
    <script>
        function checkPasswordStrength(password) {
            const meter = document.getElementById('password-strength-meter');
            const strength = calculatePasswordStrength(password);
            
            // Reset classes
            meter.className = 'strength-meter';
            
            if (password.length === 0) {
                meter.style.width = '0';
            } else if (strength < 3) {
                meter.classList.add('weak');
            } else if (strength < 6) {
                meter.classList.add('medium');
            } else {
                meter.classList.add('strong');
            }
        }
        
        function calculatePasswordStrength(password) {
            let strength = 0;
            
            // Length contributes up to 4 points
            strength += Math.min(4, Math.floor(password.length / 2));
            
            // Contains both lower and upper case
            if (password.match(/([a-z].*[A-Z])|([A-Z].*[a-z])/)) strength += 1;
            
            // Contains numbers
            if (password.match(/[0-9]/)) strength += 1;
            
            // Contains special characters
            if (password.match(/[^a-zA-Z0-9]/)) strength += 1;
            
            return strength;
        }
    </script>
</body>
</html>