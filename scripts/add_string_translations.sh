#!/bin/bash

# 批量添加多语言字符串脚本
# 使用方法: ./add_string_translations.sh <string_key> <english_text>
# 例如: ./add_string_translations.sh "auth.access_message" "Please authenticate to access your wallet"

# 检查参数
if [ $# -ne 2 ]; then
    echo "使用方法: $0 <string_key> <english_text>"
    echo "例如: $0 \"auth.access_message\" \"Please authenticate to access your wallet\""
    exit 1
fi

STRING_KEY="$1"
ENGLISH_TEXT="$2"

# 定义语言和翻译的函数
get_translation() {
    local lang_code="$1"
    case "$lang_code" in
        "values") echo "$ENGLISH_TEXT" ;;
        "values-zh-rCN") echo "请验证身份以访问您的钱包" ;;
        "values-zh-rTW") echo "請驗證身份以訪問您的錢包" ;;
        "values-de") echo "Bitte authentifizieren Sie sich, um auf Ihr Wallet zuzugreifen" ;;
        "values-fr") echo "Veuillez vous authentifier pour accéder à votre portefeuille" ;;
        "values-es") echo "Por favor autentíquese para acceder a su billetera" ;;
        "values-it") echo "Si prega di autenticarsi per accedere al portafoglio" ;;
        "values-pt-rBR") echo "Por favor, autentique-se para acessar sua carteira" ;;
        "values-ru") echo "Пожалуйста, пройдите аутентификацию для доступа к кошельку" ;;
        "values-pl") echo "Proszę uwierzytelnić się, aby uzyskać dostęp do portfela" ;;
        "values-uk") echo "Будь ласка, пройдіть автентифікацію для доступу до гаманця" ;;
        "values-nl") echo "Verifieer uzelf om toegang te krijgen tot uw portemonnee" ;;
        "values-da") echo "Godkend venligst for at få adgang til din tegnebog" ;;
        "values-cs") echo "Prosím ověřte se pro přístup k vaší peněžence" ;;
        "values-ro") echo "Vă rugăm să vă autentificați pentru a accesa portofelul" ;;
        "values-ja") echo "ウォレットにアクセスするために認証してください" ;;
        "values-ko") echo "지갑에 액세스하려면 인증하세요" ;;
        "values-hi") echo "अपने वॉलेट तक पहुंचने के लिए कृपया प्रमाणीकरण करें" ;;
        "values-th") echo "กรุณายืนยันตัวตนเพื่อเข้าถึงกระเป๋าเงินของคุณ" ;;
        "values-vi") echo "Vui lòng xác thực để truy cập ví của bạn" ;;
        "values-id") echo "Harap autentikasi untuk mengakses dompet Anda" ;;
        "values-ms") echo "Sila sahkan untuk mengakses dompet anda" ;;
        "values-bn") echo "আপনার ওয়ালেট অ্যাক্সেস করতে অনুগ্রহ করে প্রমাণীকরণ করুন" ;;
        "values-fil") echo "Mangyaring mag-authenticate upang ma-access ang inyong wallet" ;;
        "values-ar") echo "يرجى المصادقة للوصول إلى محفظتك" ;;
        "values-fa") echo "لطفاً برای دسترسی به کیف پول خود احراز هویت کنید" ;;
        "values-iw") echo "אנא אמת את זהותך כדי לגשת לארנק שלך" ;;
        "values-tr") echo "Cüzdanınıza erişmek için lütfen kimlik doğrulaması yapın" ;;
        "values-ur") echo "اپنے والیٹ تک رسائی کے لیے برائے کرم تصدیق کریں" ;;
        "values-sw") echo "Tafadhali thibitisha ili kufikia pochi yako" ;;
        *) echo "$ENGLISH_TEXT" ;;
    esac
}

# 定义支持的语言代码（只包含实际存在的文件）
# UI 模块支持的所有语言
UI_LANG_CODES="values values-ar values-bn values-cs values-da values-de values-es values-fa values-fil values-fr values-hi values-id values-it values-iw values-ja values-ko values-ms values-nl values-pl values-pt-rBR values-ro values-ru values-sw values-th values-tr values-uk values-ur values-vi values-zh-rCN values-zh-rTW"

# Localize 模块支持的语言（部分语言）
LOCALIZE_LANG_CODES="values values-ar values-de values-es values-fa values-fr values-hi values-id values-it values-iw values-ja values-ko values-pl values-pt-rBR values-ru values-th values-tr values-uk values-vi values-zh-rCN values-zh-rTW"

# 定义需要处理的目录
MODULES="ui localize"

echo "🚀 开始添加字符串翻译..."
echo "📝 字符串键: $STRING_KEY"
echo "🌐 英文文本: $ENGLISH_TEXT"
echo ""

TOTAL_ADDED=0

# 遍历每个模块
for module in $MODULES; do
    echo "📁 处理模块: $module"
    
    # 根据模块选择对应的语言代码列表
    if [ "$module" = "ui" ]; then
        LANG_CODES="$UI_LANG_CODES"
    elif [ "$module" = "localize" ]; then
        LANG_CODES="$LOCALIZE_LANG_CODES"
    else
        LANG_CODES="$UI_LANG_CODES"  # 默认使用 UI 的语言列表
    fi
    
    # 遍历每种语言
    for lang_code in $LANG_CODES; do
        translation=$(get_translation "$lang_code")
        file_path="$module/src/main/res/$lang_code/strings.xml"
        
        # 检查文件是否存在
        if [ -f "$file_path" ]; then
            # 检查字符串是否已存在
            if grep -q "name=\"$STRING_KEY\"" "$file_path"; then
                echo "  ⚠️  跳过 $lang_code (已存在)"
            else
                # 转义特殊字符
                escaped_translation=$(echo "$translation" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&apos;/g')
                
                # 在 </resources> 之前添加新字符串
                sed -i '' "s|</resources>|  <string name=\"$STRING_KEY\">$escaped_translation</string>\n</resources>|" "$file_path"
                echo "  ✅ 添加 $lang_code: $translation"
                TOTAL_ADDED=$((TOTAL_ADDED + 1))
            fi
        else
            echo "  ❌ 文件不存在: $file_path"
        fi
    done
    echo ""
done

echo "🎉 完成！总共添加了 $TOTAL_ADDED 个翻译"
echo ""
echo "📋 添加的字符串键: $STRING_KEY"
echo "📝 在代码中使用: getString(R.string.$(echo $STRING_KEY | tr '.' '_'))"
echo "📝 在 Compose 中使用: stringResource(R.string.$(echo $STRING_KEY | tr '.' '_'))"
