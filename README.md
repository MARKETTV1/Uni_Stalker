
#!/bin/sh

# ألوان للoutput
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# متغيرات الملف
PLUGIN_URL="https://github.com/MARKETTV1/Uni_Stalker/raw/refs/heads/main/Uni_stalker.tar.gz"
TMP_DIR="/tmp"
PLUGIN_NAME="Uni_Stalker"
TMP_FILE="$TMP_DIR/$PLUGIN_NAME.tar.gz"

# دالة للطباعة الملونة
print_status() {
    echo "${GREEN}✅ $1${NC}"
}

print_error() {
    echo "${RED}❌ $1${NC}"
}

print_warning() {
    echo "${YELLOW}⚠️  $1${NC}"
}

# التحقق من صلاحية المستخدم
if [ $(id -u) -ne 0 ]; then
    print_error "يجب تشغيل السكريبت كـ root أو باستخدام sudo"
    exit 1
fi

# التحقق من وجود wget
if ! command -v wget >/dev/null 2>&1; then
    print_error "wget غير مثبت. جاري التثبيت..."
    opkg update >/dev/null 2>&1 && opkg install wget >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        print_error "فشل في تثبيت wget"
        exit 1
    fi
fi

print_status "بدء تثبيت Uni_Stalker plugin"

# الخطوة 1: تحميل الملف
print_status "جاري تحميل الملف من $PLUGIN_URL"
wget -q "$PLUGIN_URL" -O "$TMP_FILE"

if [ $? -ne 0 ]; then
    print_error "فشل في تحميل الملف"
    exit 1
fi

# الخطوة 2: التحقق من الملف المحمل
if [ ! -f "$TMP_FILE" ]; then
    print_error "الملف لم يتم تحميله بشكل صحيح"
    exit 1
fi

print_status "تم تحميل الملف بنجاح: $(ls -la $TMP_FILE)"

# الخطوة 3: extract to root
print_status "جاري extract to root للملف المضغوط"
tar -xzf "$TMP_FILE" -C /

if [ $? -ne 0 ]; then
    print_error "فشل في extract to root"
    rm -f "$TMP_FILE"
    exit 1
fi

# الخطوة 4: التحقق من الملفات المستخرجة
print_status "جاري التحقق من الملفات المستخرجة"

# البحث عن ملفات البلوجين في النظام
PLUGIN_FOUND=$(find /usr -name "*Stalker*" -type d 2>/dev/null | head -1)

if [ -n "$PLUGIN_FOUND" ]; then
    print_status "تم العثور على البلوجين في: $PLUGIN_FOUND"
    
    # تعديل الصلاحيات للملفات المستخرجة
    print_status "جاري تعديل الصلاحيات"
    find "$PLUGIN_FOUND" -type f -exec chmod 644 {} \;
    find "$PLUGIN_FOUND" -type d -exec chmod 755 {} \;
    chown -R root:root "$PLUGIN_FOUND"
    
else
    print_warning "لم يتم العثور على ملفات البلوجين في المسار المتوقع"
    print_status "جاري البحث في المسارات الشائعة..."
    
    # البحث في المسارات الشائعة لـ enigma2
    COMMON_PATHS="/usr/lib/enigma2/python/plugins/Extensions /usr/lib/enigma2/python/Plugins/Extensions"
    
    for path in $COMMON_PATHS; do
        if [ -d "$path/Uni_Stalker" ]; then
            print_status "تم العثور على البلوجين في: $path/Uni_Stalker"
            chmod -R 755 "$path/Uni_Stalker"
            chown -R root:root "$path/Uni_Stalker"
            PLUGIN_FOUND="$path/Uni_Stalker"
            break
        fi
    done
fi

# الخطوة 5: التنظيف
print_status "جاري تنظيف الملف المؤقت"
rm -f "$TMP_FILE"

# الخطوة 6: التأكيد النهائي
if [ -n "$PLUGIN_FOUND" ]; then
    print_status "✅ تم extract to root بنجاح!"
    echo ""
    print_status "المسار: $PLUGIN_FOUND"
    print_status "حجم المجلد: $(du -sh $PLUGIN_FOUND 2>/dev/null | cut -f1 || echo 'غير معروف')"
    echo ""
    print_warning "يرجى إعادة تشغيل enigma2 لتطبيق التغييرات:"
    echo "• init 4 && sleep 2 && init 3"
    echo "• أو إعادة تشغيل الجهاز"
else
    print_warning "تم extract to root ولكن لم يتم العثور على ملفات البلوجين بشكل مؤكد"
    print_status "يمكن البحث يدوياً: find /usr -name '*Stalker*' -type d"
fi

# عرض محتويات إذا وجدت
if [ -n "$PLUGIN_FOUND" ] && [ -d "$PLUGIN_FOUND" ]; then
    echo ""
    print_status "محتويات المجلد:"
    ls -la "$PLUGIN_FOUND"
fi


