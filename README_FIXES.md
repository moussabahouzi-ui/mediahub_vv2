# MediaHub v2 — دليل تطبيق الإصلاحات الكاملة

## 📦 الملفات المُصلحة (18 ملف)

### Workflows (8)
- `.github/workflows/_reusable-gen-check.yml`
- `.github/workflows/_reusable-lint.yml`
- `.github/workflows/_reusable-test.yml`
- `.github/workflows/_reusable-build.yml`
- `.github/workflows/_reusable-security.yml`
- `.github/workflows/pr.yml`
- `.github/workflows/main.yml`
- `.github/workflows/nightly.yml`

### Actions (4)
- `.github/actions/setup-flutter/action.yml`
- `.github/actions/setup-java/action.yml`
- `.github/actions/setup-python/action.yml`
- `.github/actions/verify-versions/action.yml`

### Tools (2)
- `tools/gen.sh`
- `tools/check_imports.sh` ⭐ جديد

### Android (2)
- `android/settings.gradle.kts`
- `android/app/build.gradle.kts`

### Config (2)
- `melos.yaml`
- `pubspec.yaml`

## 🚀 خطوات التطبيق

```bash
# 1. فك الضغط داخل مجلد المشروع
unzip mediahub_v2_all_fixes.zip

# 2. نسخ الملفات (من داخل مجلد المشروع)
cp -r mediahub_v2_all_fixes/* .

# 3. جعل السكربتات executable
chmod +x tools/gen.sh
chmod +x tools/check_imports.sh

# 4. التحقق المحلي
fvm flutter doctor
fvm exec melos bootstrap
bash tools/gen.sh
fvm flutter build apk --debug
fvm flutter build apk --release

# 5. دفع
 git add .
git commit -m "fix(ci): resolve Phase 0 build failures - all workflows + actions + tools"
git push origin main
```

## ⚠️ ملاحظات

| الميزة | الحالة |
|--------|--------|
| Chaquopy (Python embedded) | ⏸️ معطل في Phase 0 — فعّله لاحقاً |
| Release signing | 🔓 يستخدم debug signing في CI |
| `pubspec.lock` | 📌 يجب أن يكون مُرتكباً في Git |
| `requirements.lock` | 📄 يمكن أن يكون فارغاً في Phase 0 |
