# ドメイン一覧
#
#   - usr_ : ユーザドメイン
#   - prd_ : 商品ドメイン
#   - inv_ : 在庫ドメイン
#   - ord_ : 注文ドメイン
#   - cpn_ : クーポン／マーケティングドメイン
#   - adm_ : 管理ドメイン／バックオフィス
#
#   ユーザドメイン (usr_)
#
#   - usr_user (ユーザテーブル)
#
#   商品ドメイン (prd_)
#
#   - prd_spu (商品SPU（標準商品単位）)
#   - prd_sku (商品SKU（個別商品単位）)
#   - prd_sku_image (SKU画像テーブル)
#
#   在庫ドメイン (inv_)
#
#   - inv_stock (SKU在庫（単一バケット）)
#   - inv_stock_movement (在庫変動履歴)
#
#   注文ドメイン (ord_)
#
#   - ord_order (注文ヘッダ)
#   - ord_order_item (注文明細)
#   - ord_payment (決済トランザクション)
#   - ord_shipment (配送情報)
#
#   クーポン／マーケティングドメイン (cpn_)
#
#   - cpn_coupon (クーポン基本情報)
#   - cpn_coupon_audience_rule (クーポン対象ルール（ヘッダ）)
#   - cpn_coupon_audience_user (クーポン対象ルール（個別ユーザ）)
#   - cpn_coupon_audience_bucket (クーポン対象ルール（割合指定）)
#   - cpn_coupon_grant_batch (クーポン発行バッチ)
#   - cpn_coupon_inventory (クーポン在庫状態)
#   - cpn_coupon_user (ユーザ保有クーポン)
#   - cpn_coupon_user_history (ユーザ保有クーポン状態履歴)
#   - cpn_coupon_usage (クーポン利用履歴)
#
#   管理ドメイン／バックオフィス (adm_)
#
#   - （例: adm_user, adm_role, adm_permission など）



# usr_user は会員の基礎属性を保持するテーブルです。
# 外部公開用の user_code を中心に、認証状態（メール・電話）、有効フラグ、論理削除フラグを持ち、認証や本人確認に必要な情報を揃えます。
# 使用例: 会員登録時の user_code、メール認証フラグ、氏名などを保存し、ログイン判定に利用。
# Columnについては解説
# user_code: 外部連携や URL に使う公開用一意ID。
# is_active: アカウントの有効 / 無効を判定するフラグ。
# is_email_verified / is_phone_verified: 本人確認済みかを示し、機能制限の判定に利用。
CREATE TABLE usr_user
(
    id                 BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT 'ユーザID',
    user_code          VARCHAR(64)  NOT NULL DEFAULT '' COMMENT 'ユーザコード（外部公開用一意ID）',
    email              VARCHAR(255) NOT NULL UNIQUE COMMENT 'メールアドレス（一意・必須）',
    phone_number       VARCHAR(32)           DEFAULT NULL UNIQUE COMMENT '電話番号',
    first_name         VARCHAR(64)  NOT NULL DEFAULT '' COMMENT '名（任意）',
    last_name          VARCHAR(64)  NOT NULL DEFAULT '' COMMENT '姓（任意）',
    password_encrypted VARCHAR(255) NOT NULL COMMENT 'パスワード暗号化またはハッシュ',
    is_active          BOOLEAN      NOT NULL DEFAULT FALSE COMMENT 'アカウント有効フラグ',
    is_email_verified  BOOLEAN      NOT NULL DEFAULT FALSE COMMENT 'メール認証済み',
    is_phone_verified  BOOLEAN      NOT NULL DEFAULT FALSE COMMENT '電話認証済み',
    is_deleted         BOOLEAN      NOT NULL DEFAULT FALSE COMMENT '削除フラグ（論理削除）',
    created_by         VARCHAR(128) NOT NULL DEFAULT '' COMMENT '作成者ユーザ名',
    updated_by         VARCHAR(128) NOT NULL DEFAULT '' COMMENT '更新者ユーザ名',
    created_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登録日時',
    updated_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    UNIQUE KEY uq_user_email (email),
    UNIQUE KEY uq_user_phone (phone_number),
    KEY idx_users_created_at (created_at),
    UNIQUE KEY uq_usr_user_code (user_code)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='ユーザテーブル';


# prd_spu は商品マスターの上位概念（SPU）を管理するテーブルです。
# ブランド・カテゴリなどの共通属性をまとめ、SKU や商品画像テーブルと連携して商品情報の整理・検索を容易にします。
# 使用例: レディースシャツの SPU を登録し、カラー別の SKU と画像を紐付けて商品ページを構成する。
# Columnについては解説
# spu_code: 外部システム連携や一括登録で使う管理用コード。
# brand / category: 商品の軸情報。検索・分類・分析のキーとなる。
CREATE TABLE prd_spu
(
    id         BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT 'SPU ID',
    spu_code   VARCHAR(64)  NOT NULL DEFAULT '' COMMENT 'SPUコード（外部連携や管理用）',
    spu_name   VARCHAR(255) NOT NULL DEFAULT '' COMMENT '商品名',
    brand      VARCHAR(100) NOT NULL DEFAULT '' COMMENT 'ブランド名',
    category   VARCHAR(32)  NOT NULL DEFAULT '' COMMENT 'カテゴリ',
    is_deleted BOOLEAN      NOT NULL DEFAULT FALSE COMMENT '削除フラグ（論理削除）',
    created_by VARCHAR(128) NOT NULL DEFAULT '' COMMENT '作成者ユーザ名',
    updated_by VARCHAR(128) NOT NULL DEFAULT '' COMMENT '更新者ユーザ名',
    created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登録日時',
    updated_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    UNIQUE KEY uq_prd_spu_code (spu_code)
)
    ENGINE = InnoDB
    DEFAULT CHARSET = utf8mb4 COMMENT ='商品SPU（標準商品単位）';


# prd_sku は SPU に紐づく販売単位（SKU）を保持するテーブルです。
# SKUコードやサイズ・カラーなどのバリエーション属性を管理し、商品検索や外部連携に活用します。価格系カラムと監査項目を備え、商品マスター運用や在庫連携の整合性を取りやすくしています。
# 使用例: レディースシャツ SPU に対して「ブルー/M サイズ」や「ホワイト/L サイズ」の SKU を登録。
# Columnについては解説
# sku_code: 倉庫・EC を横断して使う一意コード。
# size / color: バリエーション属性。フィルタや在庫連携のキー。
CREATE TABLE prd_sku
(
    id                BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT 'SKU ID',
    spu_id            BIGINT UNSIGNED NOT NULL COMMENT '紐づくSPU ID',
    sku_code          VARCHAR(64)     NOT NULL DEFAULT '' COMMENT 'SKUコード（外部連携や検索用）',
    size              VARCHAR(32)     NOT NULL DEFAULT '' COMMENT 'サイズ',
    color             VARCHAR(32)     NOT NULL DEFAULT '' COMMENT 'カラー',
    default_image_url VARCHAR(512)    NOT NULL DEFAULT '' COMMENT '代表画像URL',
    is_deleted        BOOLEAN         NOT NULL DEFAULT FALSE COMMENT '削除フラグ（論理削除）',
    created_by        VARCHAR(128)    NOT NULL DEFAULT '' COMMENT '作成者ユーザ名',
    updated_by        VARCHAR(128)    NOT NULL DEFAULT '' COMMENT '更新者ユーザ名',
    created_at        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登録日時',
    updated_at        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    UNIQUE KEY uq_prd_sku_code (sku_code),
    KEY idx_prd_sku_spu (spu_id)
)
    ENGINE = InnoDB
    DEFAULT CHARSET = utf8mb4 COMMENT ='商品SKU（個別商品単位）';


# prd_sku_image は SKU ごとの画像情報を保持するテーブルです。
# メイン画像フラグや表示順を管理し、商品表示や管理画面での並び替えに利用します。論理削除・監査カラムで運用履歴も追跡できます。
# 使用例: レディースシャツの「正面」「背面」「ディテール」画像を登録。
# Columnについては解説
# alt_text: 画像が表示できないときに出す代替文。アクセシビリティ対策。
# is_primary: 一覧や詳細で先頭表示するメイン画像かどうか。
# sort_order: 画像表示順を決める番号。小さい値ほど先頭。
CREATE TABLE prd_sku_image
(
    id         BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT 'SKU画像ID',
    sku_id     BIGINT UNSIGNED NOT NULL COMMENT '対象SKU ID',
    image_url  VARCHAR(512)    NOT NULL COMMENT '画像URL',
    alt_text   VARCHAR(255)    NOT NULL DEFAULT '' COMMENT '代替テキスト',
    is_primary BOOLEAN         NOT NULL DEFAULT FALSE COMMENT 'メイン画像フラグ',
    sort_order INT             NOT NULL DEFAULT 0 COMMENT '表示順',
    is_deleted BOOLEAN         NOT NULL DEFAULT FALSE COMMENT '削除フラグ（論理削除）',
    created_by VARCHAR(128)    NOT NULL DEFAULT '' COMMENT '作成者ユーザ名',
    updated_by VARCHAR(128)    NOT NULL DEFAULT '' COMMENT '更新者ユーザ名',
    created_at DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登録日時',
    updated_at DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    KEY idx_prd_sku_image_sku (sku_id)
)
    ENGINE = InnoDB
    DEFAULT CHARSET = utf8mb4 COMMENT ='SKU画像テーブル';


# inv_stock は SKU 単位の在庫残高を管理するテーブルです。
# 可用数量・予約数量・安全在庫を保持し、version 列で楽観ロックを行います。EC・OMS・倉庫システム間の在庫同期で基準となる値です。
# 使用例: 「ブルー/M サイズ」SKU の可用在庫 120 点、予約在庫 5 点、安全在庫 10 点を記録。
# Columnについては解説
# available_quantity: 現在販売可能な在庫数。入庫で増え、出荷で減る。
# reserved_quantity: 注文などで確保した在庫数。予約で増え、出荷やキャンセルで減る。
# safety_stock: 最低限残す安全在庫。閾値を下回ったら補充や制限を促す。
CREATE TABLE inv_stock
(
    id                 BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT '在庫ID',
    sku_id             BIGINT UNSIGNED NOT NULL COMMENT '対象SKU ID',
    available_quantity INT UNSIGNED    NOT NULL DEFAULT 0 COMMENT '可用在庫数量',
    reserved_quantity  INT UNSIGNED    NOT NULL DEFAULT 0 COMMENT '予約済み数量',
    safety_stock       INT UNSIGNED    NOT NULL DEFAULT 0 COMMENT '安全在庫',
    version            INT UNSIGNED    NOT NULL DEFAULT 0 COMMENT 'バージョン（楽観ロック用）',
    is_deleted         BOOLEAN         NOT NULL DEFAULT FALSE COMMENT '削除フラグ（論理削除）',
    created_by         VARCHAR(128)    NOT NULL DEFAULT '' COMMENT '作成者ユーザ名',
    updated_by         VARCHAR(128)    NOT NULL DEFAULT '' COMMENT '更新者ユーザ名',
    created_at         DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登録日時',
    updated_at         DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    UNIQUE KEY uq_inv_stock_sku (sku_id)
)
    ENGINE = InnoDB
    DEFAULT CHARSET = utf8mb4 COMMENT ='SKU在庫（単一バケット）';


# inv_stock_movement は在庫変動を履歴として保持するテーブルです。
# 変動種別や発生元情報、変動後在庫を記録し、在庫調査・会計監査・指標分析（回転率など）に活用します。
# 使用例: 入庫イベントで +50、注文引当で -1 といった変動を記録し、残数や出所を追跡。
# Columnについては解説
# change_type: INBOUND(入庫)/OUTBOUND(出庫)/RESERVE(引当)/RELEASE(解放) などのイベント種別。
# source_type / source_id: 発生元の種別（ORDER/PROCUREMENT 等）と、その ID をペアで保持。
CREATE TABLE inv_stock_movement
(
    id                       BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT '在庫変動ID',
    sku_id                   BIGINT UNSIGNED NOT NULL COMMENT '対象SKU ID',
    change_type              VARCHAR(32)     NOT NULL DEFAULT '' COMMENT '変動種別（INBOUND/OUTBOUND/RESERVE/RELEASE 等）',
    change_quantity          INT             NOT NULL COMMENT '変動数量（マイナスは減少）',
    available_quantity_after INT UNSIGNED    NOT NULL DEFAULT 0 COMMENT '変動後可用在庫',
    reserved_quantity_after  INT UNSIGNED    NOT NULL DEFAULT 0 COMMENT '変動後予約在庫',
    source_type              VARCHAR(32)     NOT NULL DEFAULT '' COMMENT '発生元種別',
    source_id                VARCHAR(64)     NOT NULL DEFAULT '' COMMENT '発生元ID',
    memo                     VARCHAR(255)    NOT NULL DEFAULT '' COMMENT '補足メモ',
    created_by               VARCHAR(128)    NOT NULL DEFAULT '' COMMENT '作成者ユーザ名',
    updated_by               VARCHAR(128)    NOT NULL DEFAULT '' COMMENT '更新者ユーザ名',
    created_at               DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登録日時',
    updated_at               DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    KEY idx_inv_stock_movement_sku (sku_id),
    KEY idx_inv_stock_movement_created_at (created_at)
)
ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='在庫変動履歴';


# cpn_coupon はクーポンの基本定義を管理するテーブルです。
# 割引タイプ・金額・利用上限・期間などのルールを保持し、発券・適用フローで参照されます。version 列による楽観ロックで運用変更の競合を防ぎます。
# 使用例: 「母の日 定額OFF（ex. 10$ discount）か、定率OFF（ex. 10% discount、有効期間や利用上限を設定。
# Columnについては解説
# discount_type: 固定額/％などの割引種別。金額計算ロジックを切り替える。
# discount_amount / discount_rate: 割引の基準値。type に応じて片方を利用。
# total_issue_limit / per_user_limit: 発行・利用の上限。0 なら無制限。
# start_at / end_at: クーポンの有効期間。判定時の基本条件。
CREATE TABLE cpn_coupon
(
    id                  BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT 'クーポンID',
    coupon_code         VARCHAR(64)    NOT NULL DEFAULT '' COMMENT 'クーポンコード（外部公開用一意ID）',
    coupon_name         VARCHAR(128)   NOT NULL DEFAULT '' COMMENT 'クーポン名称',
    description         VARCHAR(255)            DEFAULT '' COMMENT '概要・説明',
    discount_type       VARCHAR(16)    NOT NULL DEFAULT '' COMMENT '割引タイプ（FIXED=定額/PERCENT=定率 など）',
    discount_amount     DECIMAL(10, 2) NOT NULL DEFAULT 0.00 COMMENT '定額割引額',
    discount_rate       DECIMAL(5, 2)  NOT NULL DEFAULT 0.00 COMMENT '定率割引率（%）',
    min_order_amount    DECIMAL(10, 2) NOT NULL DEFAULT 0.00 COMMENT '利用条件：最低注文金額',
    max_discount_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00 COMMENT '定率時の最大割引額',
    total_issue_limit   INT UNSIGNED   NOT NULL DEFAULT 0 COMMENT '発行可能総数（0は無制限）',
    total_use_limit     INT UNSIGNED   NOT NULL DEFAULT 0 COMMENT '全体利用上限（0は無制限）',
    per_user_limit      INT UNSIGNED   NOT NULL DEFAULT 1 COMMENT 'ユーザごとの利用上限（0は無制限）',
    start_at            DATETIME       NOT NULL COMMENT '利用開始日時',
    end_at              DATETIME       NOT NULL COMMENT '利用終了日時',
    status              VARCHAR(16)    NOT NULL DEFAULT 'DRAFT' COMMENT '状態（DRAFT/ACTIVE/INACTIVE/ENDED）',
    version             INT UNSIGNED   NOT NULL DEFAULT 0 COMMENT 'バージョン（楽観ロック用）',
    is_deleted          BOOLEAN        NOT NULL DEFAULT FALSE COMMENT '削除フラグ（論理削除）',
    created_by          VARCHAR(128)   NOT NULL DEFAULT '' COMMENT '作成者ユーザ名',
    updated_by          VARCHAR(128)   NOT NULL DEFAULT '' COMMENT '更新者ユーザ名',
    created_at          DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
    updated_at          DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    UNIQUE KEY uq_cpn_coupon_code (coupon_code),
    KEY idx_cpn_coupon_period (start_at, end_at)
)
    ENGINE = InnoDB
    DEFAULT CHARSET = utf8mb4 COMMENT ='クーポン基本情報';

# cpn_coupon_audience_rule はクーポン対象者設定のヘッダを管理するテーブルです。
# 対象タイプ、優先度、除外フラグを定義し、子テーブル（ユーザ・割合など）と組み合わせて柔軟な対象条件を表現します。
# 使用例: rule_type='USER_CODE' でユーザAのみ許可、rule_type='PERCENT_BUCKET' で全体の10%を対象にすることが出来る。
# Columnについては解説
# rule_type: 判定方式（ALL_USERS=全員、USER_CODE=個別指定、PERCENT_BUCKET=割合配布 など）。
# priority: ルール評価の順番。数値が小さいほど先に判定。
# is_exclusion: TRUE の場合は対象から外す除外条件として扱う。
CREATE TABLE cpn_coupon_audience_rule
(
    id           BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT 'クーポン対象ルールID',
    coupon_id    BIGINT UNSIGNED NOT NULL COMMENT '対象クーポンID',
    rule_type    VARCHAR(32)     NOT NULL DEFAULT '' COMMENT 'ルール種別（USER/PERCENTなど）',
    priority     INT             NOT NULL DEFAULT 0 COMMENT '評価順序（小さいほど先に適用）',
    is_exclusion BOOLEAN         NOT NULL DEFAULT FALSE COMMENT '除外フラグ（trueなら対象から外す）',
    is_deleted   BOOLEAN         NOT NULL DEFAULT FALSE COMMENT '削除フラグ（論理削除）',
    created_by   VARCHAR(128)    NOT NULL DEFAULT '' COMMENT '作成者ユーザ名',
    updated_by   VARCHAR(128)    NOT NULL DEFAULT '' COMMENT '更新者ユーザ名',
    created_at   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
    updated_at   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    KEY idx_cpn_audience_rule_coupon (coupon_id))
ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='クーポン対象ルール（ヘッダ）';


# cpn_coupon_audience_user は個別ユーザを対象とするルールの明細テーブルです。
# ルールIDと user_id/user_code を紐付け、名簿配布や除外リストを表現します。一意制約と監査項目で運用ミスを防ぎます。
# 使用例: 「user_code=U12345,U12346 に配布」「user_code=U99999 を除外」といった名簿を登録。
# Columnについては解説
# rule_id: ヘッダルールとの関連。対象クーポンや優先度を決定。
# user_id / user_code: ユーザIDと公開コード。JOIN や変更追跡のため両方保持。
CREATE TABLE cpn_coupon_audience_user
(
    id         BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT 'クーポン個別ユーザ対象ID',
    rule_id    BIGINT UNSIGNED NOT NULL COMMENT '対応するルールID',
    user_id    BIGINT UNSIGNED NOT NULL COMMENT '対象ユーザID',
    user_code  VARCHAR(64)     NOT NULL COMMENT '対象ユーザコード',
    is_deleted BOOLEAN         NOT NULL DEFAULT FALSE COMMENT '削除フラグ（論理削除）',
    created_by VARCHAR(128)    NOT NULL DEFAULT '' COMMENT '作成者ユーザ名',
    updated_by VARCHAR(128)    NOT NULL DEFAULT '' COMMENT '更新者ユーザ名',
    created_at DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
    updated_at DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    UNIQUE KEY uq_cpn_audience_user_rule (rule_id, user_id),
    UNIQUE KEY uq_cpn_audience_user_rule_code (rule_id, user_code),
    KEY idx_cpn_audience_user_rule (rule_id),
    KEY idx_cpn_audience_user_id (user_id),
    KEY idx_cpn_audience_user_code (user_code)
)
ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='クーポン対象ルール（個別ユーザ）';


# cpn_coupon_audience_bucket はハッシュ分割による割合配布ルールを保持するテーブル。
# 使用例: bucket_modulus=100, start=0, end=9 で全ユーザの 10% にランダム配布。
# CRC32 を使った実例です。ルールは hash_algorithm=CRC32, bucket_modulus=100, bucket_start=0, bucket_end=9（→ 全ユーザの約 10％を対象）とします。
#
#   user_code   CRC32(16進)   CRC32 % 100   判定
#   ------------------------------------------------
#   US123456    0xd269a323          3      0〜9 に入るので命中
#   US238765    0x0efec31c         16      10以上なので対象外
#   VIP0001     0x97f5bc64         64      対象外
#   VIP0002     0x0efcedde         90      対象外

# Columnについては解説
# bucket_modulus: ハッシュの分母。100 なら 0〜99 の 100 分割。
# bucket_start / bucket_end: 配布対象とするバケット範囲。
# hash_algorithm: クライアントと合わせるハッシュ方式（既定は CRC32）。
CREATE TABLE cpn_coupon_audience_bucket
(
    id             BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT 'クーポン割合対象ID',
    rule_id        BIGINT UNSIGNED NOT NULL COMMENT '対応するルールID',
    hash_algorithm VARCHAR(32)     NOT NULL DEFAULT 'CRC32' COMMENT '使用するハッシュアルゴリズム',
    bucket_modulus INT UNSIGNED    NOT NULL COMMENT 'ユーザコードをハッシュ化し、この値で割って桶を決定する分母（例:100なら0〜99の100桶）',
    bucket_start   INT UNSIGNED    NOT NULL COMMENT '許容バケット開始（含む。例:0なら最初の桶から）',
    bucket_end     INT UNSIGNED    NOT NULL COMMENT '許容バケット終了（含む。例:9なら10桶=10%をカバー）',
    is_deleted     BOOLEAN         NOT NULL DEFAULT FALSE COMMENT '削除フラグ（論理削除）',
    created_by     VARCHAR(128)    NOT NULL DEFAULT '' COMMENT '作成者ユーザ名',
    updated_by     VARCHAR(128)    NOT NULL DEFAULT '' COMMENT '更新者ユーザ名',
    created_at     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
    updated_at     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    UNIQUE KEY uq_cpn_audience_bucket_range (rule_id, bucket_start, bucket_end),
    KEY idx_cpn_audience_bucket_rule (rule_id)
)
ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='クーポン対象ルール（割合指定）';


# cpn_coupon_inventory はクーポンの発行枚数・利用枚数・ロック枚数を管理するテーブルです。
# 上限値（発行可能枚数など）は cpn_coupon テーブルの total_issue_limit に保持しています。 cpn_coupon_inventory では現時点の発行数／使用数とバージョン管理だけを扱い、上限自体は参照する形です。
# version 列による楽観ロックで発券/利用処理の整合を保ちます。
# 使用例: クーポン CPN1001 で issued=2000、redeemed=1500、locked=20 を記録し残枚数を算出。
# Columnについては解説
# issued_count: これまで発行済みの枚数。増加のみ。
# redeemed_count: 利用済み枚数。クーポン使用確定時に増える。
# locked_count: 一時的に確保している枚数。予約/カート滞留で増減。
CREATE TABLE cpn_coupon_inventory
(
    id                 BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT 'クーポン在庫ID',
    coupon_id          BIGINT UNSIGNED NOT NULL COMMENT '対象クーポンID',
    issued_count       INT UNSIGNED    NOT NULL DEFAULT 0 COMMENT '発行済み枚数',
    redeemed_count     INT UNSIGNED    NOT NULL DEFAULT 0 COMMENT '利用済み枚数',
    locked_count       INT UNSIGNED    NOT NULL DEFAULT 0 COMMENT 'ロック中枚数（仮押さえ）',
    version            INT UNSIGNED    NOT NULL DEFAULT 0 COMMENT 'バージョン（楽観ロック用）',
    is_deleted         BOOLEAN         NOT NULL DEFAULT FALSE COMMENT '削除フラグ（論理削除）',
    created_by         VARCHAR(128)    NOT NULL DEFAULT '' COMMENT '作成者ユーザ名',
    updated_by         VARCHAR(128)    NOT NULL DEFAULT '' COMMENT '更新者ユーザ名',
    created_at         DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
    updated_at         DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    UNIQUE KEY uq_cpn_coupon_inventory (coupon_id)
)
    ENGINE = InnoDB
    DEFAULT CHARSET = utf8mb4 COMMENT ='クーポン在庫状態';


# cpn_coupon_grant_batch はクーポンの一括発行ジョブを管理します。
# クーポンを主动配布するときに使う管理テーブルで、バッチごとの発行枚数や状態を記録します。ユーザー自身がクーポンを受け取る場合は、このテーブルにレコードは作成されません。
# 使用例: 「ブラックフライデーキャンペーン」で 5 万枚配布する夜間バッチを記録。
# Columnについては解説
# grant_method: MANUAL/EVENT などの発行方法。レポート集計の軸。
# planned_quantity / granted_quantity: 予定と実績の枚数。進捗確認に利用。
# status: PENDING/COMPLETED などの実行状態。
# scheduled_at / started_at / completed_at: バッチ実行のタイムスタンプ。
CREATE TABLE cpn_coupon_grant_batch
(
    id                   BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT 'クーポン発行バッチID',
    coupon_id            BIGINT UNSIGNED NOT NULL COMMENT '対象クーポンID',
    batch_code           VARCHAR(64)     NOT NULL COMMENT 'バッチコード（管理用一意ID）',
    batch_name           VARCHAR(128)            DEFAULT '' COMMENT 'バッチ名称/メモ',
    grant_method         VARCHAR(32)     NOT NULL DEFAULT '' COMMENT '発行方法（MANUAL/EVENTなど）',
    target_rule_id       BIGINT UNSIGNED         DEFAULT NULL COMMENT '対象ルールID（該当する場合）',
    target_segment_desc  VARCHAR(255)            DEFAULT '' COMMENT '対象セグメント説明（静的リストなど）',
    planned_quantity     INT UNSIGNED    NOT NULL DEFAULT 0 COMMENT '予定発行数（0は未設定）',
    granted_quantity     INT UNSIGNED    NOT NULL DEFAULT 0 COMMENT '実際に発行した券枚数',
    failed_quantity      INT UNSIGNED    NOT NULL DEFAULT 0 COMMENT '発行失敗数',
    status               VARCHAR(32)     NOT NULL DEFAULT 'PENDING' COMMENT '状態（PENDING/RUNNING/COMPLETED/FAILED/CANCELED）',
    scheduled_at         DATETIME                DEFAULT NULL COMMENT '予約実行日時',
    started_at           DATETIME                DEFAULT NULL COMMENT '実行開始日時',
    completed_at         DATETIME                DEFAULT NULL COMMENT '完了日時',
    is_deleted           BOOLEAN         NOT NULL DEFAULT FALSE COMMENT '削除フラグ（論理削除）',
    created_by           VARCHAR(128)    NOT NULL DEFAULT '' COMMENT '作成者ユーザ名',
    updated_by           VARCHAR(128)    NOT NULL DEFAULT '' COMMENT '更新者ユーザ名',
    created_at           DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
    updated_at           DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    UNIQUE KEY uq_cpn_coupon_grant_batch_code (batch_code),
    KEY idx_cpn_coupon_grant_batch_coupon (coupon_id),
    KEY idx_cpn_coupon_grant_batch_status (status),
    KEY idx_cpn_coupon_grant_batch_schedule (scheduled_at)
)
    ENGINE = InnoDB
    DEFAULT CHARSET = utf8mb4 COMMENT ='クーポン発行バッチ';


# cpn_coupon_user はユーザが保有するクーポンチケットを管理するテーブルです。
# 取得方法やステータス、仮押さえ情報を保持し、利用上限の判定や利用状況の追跡に利用します。
# 使用例: ユーザ U12345 が「母の日 500 円OFF」を取得し、status を AVAILABLE→RESERVED→USED と遷移させて利用状況を管理。
# 使用例: バッチ(cpn_coupon_grant_batch)でユーザ U67890 にクーポンを配布し、grant_method=BATCH・grant_batch_id=123 を記録。
# Columnについては解説
# status: AVAILABLE/RESERVED/USED などの券ステータス。
# per_user_sequence は「同じクーポンをそのユーザが何枚目として取得したか」を表す連番です。
# UNIQUE KEY (coupon_id, user_id, per_user_sequence) にしておくことで、同じ番号を重複登録しないよう制御する仕組みです（＝上限超過を防ぐ）。

# reserved_order_id / reserved_expire_at: どの注文で仮押さえ中かと、解放期限。
# used_order_id / used_order_code: 実際に利用した注文を追跡。
# per_user_sequence は「同じクーポンをそのユーザが何枚目として取得したか」を表す連番です。
CREATE TABLE cpn_coupon_user
(
    id                BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT 'ユーザ保有クーポンID',
    coupon_id         BIGINT UNSIGNED NOT NULL COMMENT 'クーポンID',
    user_id           BIGINT UNSIGNED NOT NULL COMMENT 'ユーザID',
    user_code         VARCHAR(64)     NOT NULL COMMENT 'ユーザコード',
    grant_method      VARCHAR(32)     NOT NULL DEFAULT '' COMMENT '取得方法（SELF/BATCH/EVENTなど）',
    grant_batch_id    BIGINT UNSIGNED         DEFAULT NULL COMMENT '発行バッチID（該当する場合）',
    granted_at        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '取得日時',
    status            VARCHAR(16)     NOT NULL DEFAULT 'AVAILABLE' COMMENT '状態（AVAILABLE/RESERVED/USED/EXPIRED/REVOKED）',
    used_at           DATETIME                DEFAULT NULL COMMENT '利用日時',
    expired_at        DATETIME                DEFAULT NULL COMMENT '失効日時',
    revoke_reason     VARCHAR(255)            DEFAULT '' COMMENT '取り消し理由など',
    per_user_sequence INT UNSIGNED    NOT NULL DEFAULT 0 COMMENT 'ユーザ内連番（利用上限管理用）',
    reserved_at       DATETIME                DEFAULT NULL COMMENT '仮押さえ日時',
    reserved_order_id BIGINT UNSIGNED         DEFAULT NULL COMMENT '仮押さえ対象注文ID',
    reserved_order_code VARCHAR(64)           DEFAULT NULL COMMENT '仮押さえ対象注文番号',
    reserved_expire_at DATETIME               DEFAULT NULL COMMENT '仮押さえ有効期限',
    used_order_id     BIGINT UNSIGNED         DEFAULT NULL COMMENT '利用注文ID',
    used_order_code   VARCHAR(64)             DEFAULT NULL COMMENT '利用注文番号',
    last_transition_at DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '直近状態変更日時',
    version           INT UNSIGNED    NOT NULL DEFAULT 0 COMMENT 'バージョン（楽観ロック用）',
    is_deleted        BOOLEAN         NOT NULL DEFAULT FALSE COMMENT '削除フラグ（論理削除）',
    created_by        VARCHAR(128)    NOT NULL DEFAULT '' COMMENT '作成者ユーザ名',
    updated_by        VARCHAR(128)    NOT NULL DEFAULT '' COMMENT '更新者ユーザ名',
    created_at        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
    updated_at        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    UNIQUE KEY uq_cpn_coupon_user_per_user (coupon_id, user_id, per_user_sequence),
    KEY idx_cpn_coupon_user_coupon (coupon_id),
    KEY idx_cpn_coupon_user_user (user_id),
    KEY idx_cpn_coupon_user_status (status),
    KEY idx_cpn_coupon_user_batch (grant_batch_id),
    KEY idx_cpn_coupon_user_reserved (reserved_order_id),
    KEY idx_cpn_coupon_user_used (used_order_id)
)
    ENGINE = InnoDB
    DEFAULT CHARSET = utf8mb4 COMMENT ='ユーザ保有クーポン';


# cpn_coupon_user_history はユーザ保有クーポンの状態遷移ログを保持するテーブルです。
# 変更前後のステータスや操作種別、関連注文・利用履歴を記録し、監査やトラブル調査に利用します。
# 使用例: AVAILABLE → RESERVED → USED → REFUNDED の遷移を時系列で保存し、問い合わせ対応時に参照。
# Columnについては解説
# from_status / to_status: 状態遷移の前後値。
# transition_type:  CLAIM=受け取り/発券、RESERVE=仮押さえ、APPLY=適用、RELEASE=解除、REVOKE=強制回収。 などの操作種別。
# related_order_id / related_usage_id: 連動した注文・利用履歴を追跡。
CREATE TABLE cpn_coupon_user_history
(
    id                 BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT 'ユーザ保有クーポン状態履歴ID',
    coupon_user_id     BIGINT UNSIGNED NOT NULL COMMENT 'ユーザ保有クーポンID',
    coupon_id          BIGINT UNSIGNED NOT NULL COMMENT 'クーポンID',
    coupon_code        VARCHAR(64)     NOT NULL COMMENT 'クーポンコード',
    user_id            BIGINT UNSIGNED NOT NULL COMMENT 'ユーザID',
    user_code          VARCHAR(64)     NOT NULL COMMENT 'ユーザコード',
    from_status        VARCHAR(32)     NOT NULL DEFAULT '' COMMENT '変更前状態（AVAILABLE/RESERVED/USED/EXPIRED 等）',
    to_status          VARCHAR(32)     NOT NULL COMMENT '変更後状態',
    transition_type    VARCHAR(32)     NOT NULL DEFAULT '' COMMENT '操作種別（CLAIM/RESERVE/APPLY/RELEASE/REVOKE 等）',
    related_order_id   BIGINT UNSIGNED          DEFAULT NULL COMMENT '関連注文ID',
    related_order_code VARCHAR(64)              DEFAULT NULL COMMENT '関連注文コード',
    related_usage_id   BIGINT UNSIGNED          DEFAULT NULL COMMENT '関連利用履歴ID',
    reason             VARCHAR(255)    NOT NULL DEFAULT '' COMMENT '変更理由',
    is_deleted         BOOLEAN         NOT NULL DEFAULT FALSE COMMENT '削除フラグ（論理削除）',
    created_by         VARCHAR(128)    NOT NULL DEFAULT '' COMMENT '作成者ユーザ名',
    updated_by         VARCHAR(128)    NOT NULL DEFAULT '' COMMENT '更新者ユーザ名',
    created_at         DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
    updated_at         DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    KEY idx_cpn_user_history_coupon_user (coupon_user_id),
    KEY idx_cpn_user_history_coupon (coupon_id),
    KEY idx_cpn_user_history_order (related_order_id),
    KEY idx_cpn_user_history_created_at (created_at)
)
    ENGINE = InnoDB
    DEFAULT CHARSET = utf8mb4 COMMENT ='ユーザ保有クーポン状態履歴';


# cpn_coupon_usage はクーポンの注文適用履歴を管理するテーブルです。
# 適用額・返金額・利用状態や対象注文を記録し、決済・返品・会計処理の整合を追跡します。
# 使用例: 注文 ORD-20240501 にクーポン CPN1001 を適用して 50 円割引、キャンセル時に usage_status を ROLLED_BACK に更新し、クーポンをユーザへ返す。
# Columnについては解説
# usage_status: APPLIED/ROLLED_BACK/REFUNDED などの利用状態。
# applied_amount: 例: 5000円のドレスに500円OFFクーポンを適用し、実際に割引された500円を記録。
# refunded_amount: 例: ドレスのうち2000円分だけ返品し、割引分に相当する200円を利用者へ返金した場合、その200円を記録。
# settled_amount: 例: 返品処理が完了し、最終的に消化された割引額が300円となったとき、その300円を確定額として保持。
# order_id / order_code: どの注文に紐づくかを追跡。
CREATE TABLE cpn_coupon_usage
(
    id                   BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT 'クーポン利用履歴ID',
    coupon_user_id       BIGINT UNSIGNED NOT NULL COMMENT 'ユーザ保有クーポンID',
    coupon_id            BIGINT UNSIGNED NOT NULL COMMENT 'クーポンID',
    coupon_code          VARCHAR(64)     NOT NULL COMMENT 'クーポンコード',
    user_id              BIGINT UNSIGNED NOT NULL COMMENT 'ユーザID',
    user_code            VARCHAR(64)     NOT NULL COMMENT 'ユーザコード',
    order_id             BIGINT UNSIGNED          DEFAULT NULL COMMENT '利用注文ID',
    order_code           VARCHAR(64)              DEFAULT NULL COMMENT '利用注文コード',
    usage_status         VARCHAR(32)     NOT NULL DEFAULT 'APPLIED' COMMENT '利用状態（APPLIED/ROLLED_BACK/REFUNDED 等）',
    applied_amount       DECIMAL(12, 2)  NOT NULL DEFAULT 0.00 COMMENT '適用割引額',
    refunded_amount      DECIMAL(12, 2)  NOT NULL DEFAULT 0.00 COMMENT '返金済み割引額',
    settled_amount       DECIMAL(12, 2)  NOT NULL DEFAULT 0.00 COMMENT '最終確定割引額',
    applied_at           DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '適用日時',
    settled_at           DATETIME                 DEFAULT NULL COMMENT '確定日時（返品判定や会計締め用）',
    rolled_back_at       DATETIME                 DEFAULT NULL COMMENT '取り消し日時',
    rollback_reason      VARCHAR(255)    NOT NULL DEFAULT '' COMMENT '取消理由',
    notes                VARCHAR(255)    NOT NULL DEFAULT '' COMMENT '補足メモ',
    version              INT UNSIGNED    NOT NULL DEFAULT 0 COMMENT 'バージョン（楽観ロック用）',
    is_deleted           BOOLEAN         NOT NULL DEFAULT FALSE COMMENT '削除フラグ（論理削除）',
    created_by           VARCHAR(128)    NOT NULL DEFAULT '' COMMENT '作成者ユーザ名',
    updated_by           VARCHAR(128)    NOT NULL DEFAULT '' COMMENT '更新者ユーザ名',
    created_at           DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
    updated_at           DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    KEY idx_cpn_usage_coupon_user (coupon_user_id),
    KEY idx_cpn_usage_coupon (coupon_id),
    KEY idx_cpn_usage_order (order_id),
    KEY idx_cpn_usage_status (usage_status),
    KEY idx_cpn_usage_applied_at (applied_at)
)
    ENGINE = InnoDB
    DEFAULT CHARSET = utf8mb4 COMMENT ='クーポン利用履歴';


# ord_order は EC 注文のヘッダ情報を管理するテーブルです。
# 金額内訳、状態、適用クーポンや支払・配送ステータスを一元的に保持し、決済・出荷・の各フローの起点となります。
# 使用例: ユーザ U12345 が 2024/05/01 に注文 ORD-20240501 を作成。ドレス 20,000 円とジャケット 15,000 円を購入し、subtotal_amount は 35,000 円。
#   クーポンを 2 枚使用：ドレス用に 3,000 円 OFF、ジャケット用に 2,000 円 OFF。合計割引 5,000 円が coupon_discount_amount および discount_amount に記録される。
#   商品にかかる消費税は 3,000 円、送料は 500 円。最終的に支払う total_amount は 35,000 − 5,000 + 3,000 + 500 = 33,500 円。
#   使用したクーポンごとに cpn_coupon_usage に applied_amount を残し、返品があれば refunded_amount や settled_amount に反映。ord_order の discount_amount / coupon_discount_amount から注文全体でいくら券を使ったかを把握できる。
# Columnについては解説
# subtotal_amount / discount_amount / total_amount: 金額内訳。税や割引を含め注文全体のサマリを保持。
# payment_status / shipment_status: 決済・配送の最新状態。
# coupon_id / coupon_code / coupon_discount_amount: 適用したクーポンと割引額。
# shipping_address_snapshot / billing_address_snapshot: 注文時点の住所スナップショット。
CREATE TABLE ord_order
(
    id                       BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT '注文ID',
    order_code               VARCHAR(64)     NOT NULL COMMENT '注文コード（外部公開用一意ID）',
    user_id                  BIGINT UNSIGNED NOT NULL COMMENT 'ユーザID',
    user_code                VARCHAR(64)     NOT NULL COMMENT 'ユーザコード',
    status                   VARCHAR(32)     NOT NULL DEFAULT 'CREATED' COMMENT '注文状態（CREATED/CONFIRMED/SHIPPED/COMPLETED/CANCELED 等）',
    order_type               VARCHAR(32)     NOT NULL DEFAULT 'GENERAL' COMMENT '注文タイプ（GENERAL/PREORDER 等）',
    channel                  VARCHAR(32)     NOT NULL DEFAULT '' COMMENT '注文チャネル（WEB/APP/OFFLINE など）',
    currency                 VARCHAR(8)      NOT NULL DEFAULT 'JPY' COMMENT '通貨コード',
    subtotal_amount          DECIMAL(12, 2)  NOT NULL DEFAULT 0.00 COMMENT '商品小計（税込み前）',
    discount_amount          DECIMAL(12, 2)  NOT NULL DEFAULT 0.00 COMMENT '割引合計（クーポン・プロモーション等）',
    tax_amount               DECIMAL(12, 2)  NOT NULL DEFAULT 0.00 COMMENT '税額合計',
    shipping_amount          DECIMAL(12, 2)  NOT NULL DEFAULT 0.00 COMMENT '送料',
    total_amount             DECIMAL(12, 2)  NOT NULL DEFAULT 0.00 COMMENT '支払総額（税込み）',
    coupon_id                BIGINT UNSIGNED          DEFAULT NULL COMMENT '適用クーポンID',
    coupon_code              VARCHAR(64)              DEFAULT NULL COMMENT '適用クーポンコード',
    coupon_discount_amount   DECIMAL(12, 2)  NOT NULL DEFAULT 0.00 COMMENT 'クーポン割引額',
    payment_status           VARCHAR(32)     NOT NULL DEFAULT 'PENDING' COMMENT '決済状態（PENDING/PAID/FAILED/REFUNDED 等）',
    shipment_status          VARCHAR(32)     NOT NULL DEFAULT 'PENDING' COMMENT '出荷状態（PENDING/SHIPPED/DELIVERED 等）',
    ordered_at               DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注文日時',
    cancelled_at             DATETIME                 DEFAULT NULL COMMENT 'キャンセル日時',
    notes                    VARCHAR(255)    NOT NULL DEFAULT '' COMMENT '備考（オペレーション向けメモ）',
    shipping_address_snapshot JSON                   DEFAULT NULL COMMENT '配送先スナップショット（JSON）',
    billing_address_snapshot JSON                    DEFAULT NULL COMMENT '請求先スナップショット（JSON）',
    version                  INT UNSIGNED     NOT NULL DEFAULT 0 COMMENT 'バージョン（楽観ロック用）',
    is_deleted               BOOLEAN          NOT NULL DEFAULT FALSE COMMENT '削除フラグ（論理削除）',
    created_by               VARCHAR(128)     NOT NULL DEFAULT '' COMMENT '作成者ユーザ名',
    updated_by               VARCHAR(128)     NOT NULL DEFAULT '' COMMENT '更新者ユーザ名',
    created_at               DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
    updated_at               DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    UNIQUE KEY uq_ord_order_code (order_code),
    KEY idx_ord_order_user (user_id),
    KEY idx_ord_order_status (status),
    KEY idx_ord_order_payment_status (payment_status),
    KEY idx_ord_order_shipment_status (shipment_status),
    KEY idx_ord_order_created_at (created_at),
    KEY idx_ord_order_coupon (coupon_id)
)
    ENGINE = InnoDB
    DEFAULT CHARSET = utf8mb4 COMMENT ='注文ヘッダ';


# ord_order_item は注文に含まれる商品明細を管理するテーブルです。
# SKU・数量・価格情報のスナップショットを保持し、在庫引当・返品・売上分析などの粒度として活用します。
# 使用例: ユーザ U12345 が 2024/05/01 に注文 ORD-20240501 を作成し、ドレス 20,000 円とジャケット 15,000 円を購入。明細レベルで見ると以下のようになります。
#
#   - 明細行1（line_number=1）ドレス 20,000 円
#     list_price=20,000、sale_price=20,000（明細レベルの追加割引なし）
#     クーポンで 3,000 円をこの行に割り当てるので discount_amount=3,000。
#     明細の total_amount は 20,000 − 3,000 = 17,000。
#   - 明細行2（line_number=2）ジャケット 15,000 円
#     list_price=15,000、sale_price=15,000。
#     クーポン割引 2,000 円を discount_amount に記録し、total_amount=15,000 − 2,000 = 13,000。
#
#   この2行の total_amount（17,000 + 13,000 = 30,000）と、注文ヘッダ（ord_order）側の税額 3,000、送料 500、クーポン割引合計 5,000 を組み合わせると、
#   注文全体の total_amount 33,500 と一致します。
#   割引をどの明細にどう配分したかを discount_amount で残しておくことで、部分返品時のクーポン返金額や売上計上の粒度を明細単位で管理できます。\
# Columnについては解説
# line_number: 注文内での明細行番号。表示順や識別に利用。
# quantity: 注文数量。返品・在庫引当の基準。
# sale_price / discount_amount / total_amount: 明細の価格情報。売上計上や割引計算に利用。
# item_status: 明細ごとの状態管理（PENDING/SHIPPED 等）。
CREATE TABLE ord_order_item
(
    id               BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT '注文明細ID',
    order_id         BIGINT UNSIGNED NOT NULL COMMENT '注文ID',
    order_code       VARCHAR(64)     NOT NULL COMMENT '注文コード',
    line_number      INT UNSIGNED    NOT NULL DEFAULT 1 COMMENT '明細行番号',
    spu_id           BIGINT UNSIGNED NOT NULL COMMENT '対象SPU ID',
    sku_id           BIGINT UNSIGNED NOT NULL COMMENT '対象SKU ID',
    sku_code         VARCHAR(64)     NOT NULL COMMENT 'SKUコード',
    product_name     VARCHAR(255)    NOT NULL DEFAULT '' COMMENT '商品名（注文時スナップショット）',
    quantity         INT UNSIGNED    NOT NULL DEFAULT 1 COMMENT '数量',
    list_price       DECIMAL(12, 2)  NOT NULL DEFAULT 0.00 COMMENT '定価単価',
    sale_price       DECIMAL(12, 2)  NOT NULL DEFAULT 0.00 COMMENT '販売単価（割引後）',
    discount_amount  DECIMAL(12, 2)  NOT NULL DEFAULT 0.00 COMMENT '明細割引額',
    tax_amount       DECIMAL(12, 2)  NOT NULL DEFAULT 0.00 COMMENT '明細税額',
    total_amount     DECIMAL(12, 2)  NOT NULL DEFAULT 0.00 COMMENT '明細合計（税抜）',
    item_status      VARCHAR(32)     NOT NULL DEFAULT 'PENDING' COMMENT '明細状態（PENDING/ALLOCATED/SHIPPED/CANCELED 等）',
    is_deleted       BOOLEAN         NOT NULL DEFAULT FALSE COMMENT '削除フラグ（論理削除）',
    created_by       VARCHAR(128)    NOT NULL DEFAULT '' COMMENT '作成者ユーザ名',
    updated_by       VARCHAR(128)    NOT NULL DEFAULT '' COMMENT '更新者ユーザ名',
    created_at       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
    updated_at       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    UNIQUE KEY uq_ord_order_item_line (order_id, line_number),
    KEY idx_ord_order_item_order (order_id),
    KEY idx_ord_order_item_code (order_code),
    KEY idx_ord_order_item_sku (sku_id),
    KEY idx_ord_order_item_status (item_status)
)
    ENGINE = InnoDB
    DEFAULT CHARSET = utf8mb4 COMMENT ='注文明細';
