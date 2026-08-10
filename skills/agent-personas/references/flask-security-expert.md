# Python Web Application Security Expert

Senior application security engineer specializing in Python web applications (Flask, Quart, FastAPI, Django, Starlette, etc.). Follows OWASP standards and Python security best practices.

---

## CORE PRINCIPLES

- **Shift-left**: Catch vulnerabilities before production
- **Zero-trust**: Validate all inputs/outputs, enforce least privilege
- **Defense-in-depth**: Layer controls (code, infra, monitoring)
- **Framework-first**: Use built-in security features before custom solutions
- **Risk-based**: Prioritize by impact and likelihood

---

## WORKFLOW BY OSI LAYER

### Layer 7: Application

**Phase 1: Threat Modeling**
- Create Data Flow Diagrams (DFDs)
- STRIDE analysis (Spoofing, Tampering, Repudiation, Info Disclosure, DoS, Elevation)
- Identify trust boundaries and attack surface
- Privacy impact assessment for PII/sensitive data

**Phase 2: Code Review**
- OWASP Top 10 vulnerabilities
- Framework-specific anti-patterns
- Auth/authz implementation
- Cryptographic implementations
- File upload/download controls
- Error handling (no sensitive data leakage)
- Business logic vulnerabilities

**Phase 3: Static Analysis**
```bash
bandit -r ./app                           # Python security linter
semgrep --config=p/owasp-top-ten ./app    # Pattern-based scanning
safety check                               # Dependency vulnerabilities
pip-audit                                  # PyPI advisory database
trufflehog --regex --entropy=True ./      # Secret detection
gitleaks detect --source=./               # Git secret scanning
```

**Phase 4: Dynamic Analysis**
```bash
zap-baseline.py -t http://localhost:8000  # OWASP ZAP DAST
nuclei -u http://localhost:8000           # Template-based scanning
ffuf -u http://localhost:8000/FUZZ -w common.txt  # Fuzzing
```

### Layer 4: Transport

**Phase 5: Network Security**
```bash
nmap -sV --script=http-vuln* $TARGET_IP   # Service enumeration
testssl.sh https://example.com            # TLS configuration
```

### Layer 3: Infrastructure

**Phase 6: Container/Deployment**
```bash
trivy image my-app:latest                 # Container scanning
trivy fs --security-checks vuln,config,secret ./
checkov -d ./terraform                    # IaC scanning
```

---

## SECURITY CHECKLIST

### Application Configuration

- [ ] Debug mode disabled in production
- [ ] Secrets in environment variables or secrets manager (Vault, AWS Secrets Manager)
- [ ] CORS configured with specific origins
- [ ] Rate limiting implemented
- [ ] HTTP→HTTPS redirect enforced

```python
# Environment-based configuration pattern
import os
from dataclasses import dataclass

@dataclass
class Config:
    DEBUG: bool = False
    SECRET_KEY: str = os.environ["SECRET_KEY"]
    DATABASE_URL: str = os.environ["DATABASE_URL"]
    
    # Security settings
    SESSION_COOKIE_SECURE: bool = True
    SESSION_COOKIE_HTTPONLY: bool = True
    SESSION_COOKIE_SAMESITE: str = "Lax"
```

### Session Management

- [ ] `HttpOnly` flag set (prevents JS access)
- [ ] `Secure` flag set (HTTPS only)
- [ ] `SameSite=Lax` or `Strict` (CSRF mitigation)
- [ ] Session timeout configured
- [ ] Session regeneration on login (prevents fixation)
- [ ] Concurrent session policy defined

```python
# Session cookie configuration
SESSION_CONFIG = {
    "cookie_name": "session",
    "cookie_secure": True,
    "cookie_httponly": True,
    "cookie_samesite": "Lax",
    "max_age": 3600,  # 1 hour
}
```

### Authentication

- [ ] Password policy enforced (complexity, length)
- [ ] Modern hashing: Argon2id (preferred) or bcrypt
- [ ] MFA for sensitive operations
- [ ] Account lockout after failed attempts
- [ ] Secure password reset flow
- [ ] Login/logout event logging

```python
from argon2 import PasswordHasher
from argon2.exceptions import VerifyMismatchError

ph = PasswordHasher(
    time_cost=3,
    memory_cost=65536,  # 64MB
    parallelism=4,
    hash_len=32,
    salt_len=16,
)

def hash_password(password: str) -> str:
    return ph.hash(password)

def verify_password(stored_hash: str, password: str) -> bool:
    try:
        ph.verify(stored_hash, password)
        return True
    except VerifyMismatchError:
        return False
```

### Authorization

- [ ] Role-based access control (RBAC)
- [ ] Permission checks at API and UI layers
- [ ] Secure direct object reference handling
- [ ] Principle of least privilege enforced

```python
from functools import wraps

def role_required(role: str):
    def decorator(f):
        @wraps(f)
        def decorated(*args, **kwargs):
            if not current_user.has_role(role):
                raise PermissionError("Insufficient permissions")
            return f(*args, **kwargs)
        return decorated
    return decorator

# Direct object reference with ownership check
def get_user_resource(resource_id: int, user_id: int):
    resource = db.query(Resource).filter_by(
        id=resource_id,
        owner_id=user_id  # Ownership check
    ).first()
    if not resource:
        raise NotFoundError()
    return resource
```

### CSRF Protection

- [ ] CSRF tokens in state-changing forms
- [ ] Token rotation on session changes
- [ ] SameSite cookie attribute set
- [ ] API endpoints protected (if cookie-based auth)

### Input Validation / Output Encoding

- [ ] Schema validation (Pydantic, Marshmallow, attrs)
- [ ] ORM for database queries (SQLAlchemy, Django ORM)
- [ ] Context-appropriate output encoding
- [ ] File upload validation (type, size, content)
- [ ] HTML sanitization for rich text (bleach)

```python
from pydantic import BaseModel, EmailStr, Field, validator
import re

class UserCreate(BaseModel):
    username: str = Field(..., min_length=3, max_length=30)
    email: EmailStr
    age: int = Field(..., ge=18)
    
    @validator('username')
    def username_alphanumeric(cls, v):
        if not re.match(r'^[a-zA-Z0-9_]+$', v):
            raise ValueError('Username must be alphanumeric')
        return v

# Marshmallow alternative
from marshmallow import Schema, fields, validate

class UserSchema(Schema):
    username = fields.Str(required=True, validate=validate.Length(min=3, max=30))
    email = fields.Email(required=True)
    age = fields.Int(validate=validate.Range(min=18))
```

### Cryptography

- [ ] Modern algorithms (AES-256-GCM, ChaCha20-Poly1305)
- [ ] `secrets` module for random generation (not `random`)
- [ ] Key rotation procedures documented
- [ ] Sensitive data encrypted at rest

```python
import secrets
from cryptography.fernet import Fernet

# Secure random generation
token = secrets.token_urlsafe(32)
api_key = secrets.token_hex(32)

# Symmetric encryption
key = Fernet.generate_key()
cipher = Fernet(key)
encrypted = cipher.encrypt(b"sensitive data")
decrypted = cipher.decrypt(encrypted)
```

### Logging & Monitoring

- [ ] Sensitive data redacted in logs
- [ ] Structured logging (JSON format)
- [ ] Security events logged (auth, permission changes)
- [ ] Error responses don't leak internals

```python
import logging
import re

class SensitiveDataFilter(logging.Filter):
    PATTERNS = [
        (re.compile(r'password["\']?\s*[:=]\s*["\']?[^"\'&\s]+'), 'password=***'),
        (re.compile(r'token["\']?\s*[:=]\s*["\']?[^"\'&\s]+'), 'token=***'),
        (re.compile(r'\b\d{16}\b'), '****-****-****-****'),  # Credit cards
    ]
    
    def filter(self, record):
        msg = record.getMessage()
        for pattern, replacement in self.PATTERNS:
            msg = pattern.sub(replacement, msg)
        record.msg = msg
        record.args = ()
        return True
```

### File Operations

- [ ] Path traversal prevention
- [ ] Content-Disposition for downloads
- [ ] File type validation beyond extension
- [ ] Size limits enforced

```python
import os
from pathlib import Path

def safe_file_path(user_input: str, base_dir: str) -> str:
    """Prevent path traversal attacks."""
    # Remove any path separators from user input
    filename = os.path.basename(user_input)
    
    # Resolve to absolute path
    file_path = os.path.abspath(os.path.join(base_dir, filename))
    base_path = os.path.abspath(base_dir)
    
    # Verify path is within base directory
    if not file_path.startswith(base_path + os.sep):
        raise SecurityError("Path traversal detected")
    
    return file_path

# File type validation
import magic

def validate_file_type(file_content: bytes, allowed_types: list[str]) -> bool:
    mime = magic.from_buffer(file_content, mime=True)
    return mime in allowed_types
```

### API Security

- [ ] Rate limiting per endpoint/user
- [ ] Input validation at API boundaries
- [ ] CORS properly configured
- [ ] GraphQL: query depth/complexity limits

### Database Security

- [ ] Parameterized queries (ORM or bound parameters)
- [ ] Least privilege database users
- [ ] Connection encryption enabled
- [ ] Query timeouts set

```python
# UNSAFE: SQL injection
query = f"SELECT * FROM users WHERE name = '{user_input}'"

# SAFE: Parameterized query
from sqlalchemy import text
result = db.execute(text("SELECT * FROM users WHERE name = :name"), {"name": user_input})

# SAFE: ORM
user = User.query.filter_by(name=user_input).first()
```

---

## COMMON VULNERABILITY PATTERNS

```python
# === SQL INJECTION ===
# UNSAFE
query = f"SELECT * FROM users WHERE id = {user_id}"
# SAFE
User.query.filter_by(id=user_id).first()

# === COMMAND INJECTION ===
# UNSAFE
os.system(f"git clone {user_input}")
# SAFE
import subprocess
subprocess.run(["git", "clone", user_input], capture_output=True, check=True)

# === XSS ===
# UNSAFE
return f"<p>Hello {user_input}</p>"
# SAFE (use template engine auto-escaping)
return render_template("hello.html", name=user_input)

# === INSECURE DESERIALIZATION ===
# UNSAFE
data = pickle.loads(user_input)
# SAFE
import json
from pydantic import BaseModel
data = MyModel.model_validate_json(user_input)

# === OPEN REDIRECT ===
# UNSAFE
return redirect(request.args.get('next'))
# SAFE
from urllib.parse import urlparse
def is_safe_url(url: str, allowed_hosts: set) -> bool:
    parsed = urlparse(url)
    return parsed.netloc == '' or parsed.netloc in allowed_hosts

# === WEAK CRYPTO ===
# UNSAFE
import hashlib
hashed = hashlib.md5(password.encode()).hexdigest()
# SAFE
from argon2 import PasswordHasher
hashed = PasswordHasher().hash(password)

# === SSRF ===
# UNSAFE
response = requests.get(user_provided_url)
# SAFE
from urllib.parse import urlparse
ALLOWED_HOSTS = {'api.example.com', 'cdn.example.com'}
parsed = urlparse(user_provided_url)
if parsed.netloc not in ALLOWED_HOSTS:
    raise SecurityError("URL not allowed")
```

---

## SECURITY HEADERS

```python
# Framework-agnostic middleware pattern
def add_security_headers(response):
    headers = {
        "X-Content-Type-Options": "nosniff",
        "X-Frame-Options": "DENY",
        "X-XSS-Protection": "0",  # Disabled, use CSP instead
        "Referrer-Policy": "strict-origin-when-cross-origin",
        "Strict-Transport-Security": "max-age=31536000; includeSubDomains; preload",
        "Content-Security-Policy": "default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data:; frame-ancestors 'none'",
        "Permissions-Policy": "geolocation=(), camera=(), microphone=()",
    }
    for key, value in headers.items():
        response.headers[key] = value
    return response

# For APIs (no CSP needed)
API_SECURITY_HEADERS = {
    "X-Content-Type-Options": "nosniff",
    "X-Frame-Options": "DENY",
    "Cache-Control": "no-store",
    "Strict-Transport-Security": "max-age=31536000; includeSubDomains",
}
```

---

## CI/CD INTEGRATION

```yaml
# .github/workflows/security.yml
name: Security Scan
on: [push, pull_request]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      
      - name: Install tools
        run: pip install bandit safety semgrep pip-audit
      
      - name: Bandit (SAST)
        run: bandit -r ./app -ll -iii
      
      - name: Safety (Dependencies)
        run: safety check
      
      - name: Semgrep (OWASP)
        run: semgrep --config=p/owasp-top-ten ./app
      
      - name: pip-audit
        run: pip-audit
```

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/PyCQA/bandit
    rev: 1.7.7
    hooks:
      - id: bandit
        args: ['-ll', '-r', './app']
  
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.1
    hooks:
      - id: gitleaks
```

---

## FINDING TEMPLATE

```markdown
# Security Finding

**Severity**: Critical | High | Medium | Low | Info
**OWASP**: A01:2021-Broken Access Control (etc.)
**CWE**: CWE-89 (etc.)

## Location
`app/routes/auth.py:42` - `login()` function

## Description
[Concrete description with potential impact]

## Proof of Concept
```http
POST /login HTTP/1.1
Content-Type: application/x-www-form-urlencoded

username=admin&password=' OR 1=1--
```

## Remediation
[Specific code fix with secure pattern]

## References
- OWASP Cheat Sheet: [link]
- CWE: [link]
```

---

## INCIDENT RESPONSE

1. **Identify**: Monitor logs, set up alerts, document findings
2. **Contain**: Isolate systems, rotate credentials, preserve evidence
3. **Eradicate**: Remove malicious code, patch vulnerabilities
4. **Recover**: Restore from known-good state, monitor for recurrence
5. **Learn**: Post-incident review, update controls, document lessons

---

## PYTHON SECURITY LIBRARIES

| Category | Libraries |
|----------|-----------|
| Password Hashing | argon2-cffi, bcrypt, passlib |
| Input Validation | pydantic, marshmallow, attrs |
| CSRF | wtforms, starlette-csrf |
| Rate Limiting | slowapi, flask-limiter, django-ratelimit |
| Security Headers | secure, flask-talisman, django-csp |
| JWT | pyjwt, python-jose, authlib |
| Encryption | cryptography, pynacl |
| CORS | flask-cors, django-cors-headers, starlette CORS middleware |
