# 用户域 (User)
#        usr_
# usr_user, usr_user_address, usr_user_login_log
# 商品域 (Product)
# prd_
# prd_product (SPU), prd_product_sku (SKU), prd_product_image
# 库存域 (Inventory)
# inv_
# inv_stock, inv_stock_movement
# 订单域 (Order)
# ord_
# ord_order, ord_order_item, ord_payment, ord_shipment
# 优惠券/营销域 (Coupon)
# cpn_
# cpn_coupon, cpn_coupon_usage, cpn_campaign
# 管理端/后台 (Admin)
# adm_
# adm_user, adm_role, adm_permission


# usr_user は会員の基礎属性を保持するテーブルです。
# 外部公開用の user_code を中心に、認証状態（メール・電話）、有効フラグ、論理削除フラグを持ち、認証や本人確認に必要な情報を揃えます。
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

# prd_sku_image は SKU ごとの画像情報を保持するテーブルです。メイン画像フラグや表示順を管理し、商品表示や
# 管理画面での並び替えに利用します。論理削除・監査カラムで運用履歴も追跡できます。
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

# inv_stock は SKU 単位の在庫残高を管理するテーブルです。可用数量・予約数量・安全在庫を保持し、version 列で
# 楽観ロックを行います。EC・OMS・倉庫システム間の在庫同期で基準となる値です。
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

# inv_stock_movement は在庫変動を履歴として保持するテーブルです。変動種別や発生元情報、変動後在庫を記録し、
# 在庫調査・会計監査・指標分析（回転率など）に活用します。
CREATE TABLE inv_stock_movement
(
    id                       BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT '在庫変動ID',
    sku_id                   BIGINT UNSIGNED NOT NULL COMMENT '対象SKU ID',
    change_type              VARCHAR(32)     NOT NULL DEFAULT '' COMMENT '変動種別（入庫・出庫など）',
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




# cpn_coupon はクーポンの基本定義を管理するテーブルです。割引タイプ・金額・利用上限・期間などのルールを保持し、
# 発券・適用フローで参照されます。version 列による楽観ロックで運用変更の競合を防ぎます。
CREATE TABLE cpn_coupon
(
    id                  BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT 'クーポンID',
    coupon_code         VARCHAR(64)    NOT NULL DEFAULT '' COMMENT 'クーポンコード（外部公開用一意ID）',
    coupon_name         VARCHAR(128)   NOT NULL DEFAULT '' COMMENT 'クーポン名称',
    description         VARCHAR(255)            DEFAULT '' COMMENT '概要・説明',
    discount_type       VARCHAR(16)    NOT NULL DEFAULT '' COMMENT '割引タイプ（FIXED/PERCENT...）',
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

# cpn_coupon_audience_rule はクーポン対象者設定のヘッダを管理するテーブルです。対象タイプ、優先度、除外フラグを
# 定義し、子テーブル（ユーザ・割合など）と組み合わせて柔軟な対象条件を表現します。
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

# cpn_coupon_audience_user は個別ユーザを対象とするルールの明細テーブルです。ルールIDと user_code を紐付け、
# 名簿配布や除外リストを表現します。一意制約と監査項目で運用ミスを防ぎます。
CREATE TABLE cpn_coupon_audience_user
(
    id         BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT 'クーポン個別ユーザ対象ID',
    rule_id    BIGINT UNSIGNED NOT NULL COMMENT '対応するルールID',
    user_code  VARCHAR(64)     NOT NULL COMMENT '対象ユーザコード',
    is_deleted BOOLEAN         NOT NULL DEFAULT FALSE COMMENT '削除フラグ（論理削除）',
    created_by VARCHAR(128)    NOT NULL DEFAULT '' COMMENT '作成者ユーザ名',
    updated_by VARCHAR(128)    NOT NULL DEFAULT '' COMMENT '更新者ユーザ名',
    created_at DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
    updated_at DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    UNIQUE KEY uq_cpn_audience_user_rule_code (rule_id, user_code),
    KEY idx_cpn_audience_user_rule (rule_id),
    KEY idx_cpn_audience_user_code (user_code)
)
ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='クーポン対象ルール（個別ユーザ）';

# cpn_coupon_audience_bucket はハッシュ分割による割合配布ルールを保持します。bucket_modulus と start/end で
# 割当割合を制御し、ランダム配布や AB テストに活用します。
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

# cpn_coupon_grant_batch はクーポンの一括発行ジョブを管理します。予定数・実績数・ステータスやスケジュールを保持し、
# イベント配布や定期配布の進捗管理に利用します。
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


# 上限値（発行可能枚数など）は cpn_coupon テーブルの total_issue_limit に保持しています。 cpn_coupon_inventory では現時点の発行数／使用数とバージョン管理だけを扱い、上限自体は参照する形です。
# cpn_coupon_inventory はクーポンの発行枚数・利用枚数・ロック枚数を管理し、version 列による楽観ロックで発券/利用処理の整合を保ちます。
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



# cpn_coupon_user はユーザが保有するクーポンチケットを管理します。取得方法やステータス、仮押さえ情報を保持し、
# 利用上限の判定や利用状況の追跡に利用します。
# per_user_sequence は「同じクーポンをそのユーザが何枚目として取得したか」を表す連番です。
-- UNIQUE KEY (coupon_id, user_id, per_user_sequence) にしておくことで、同じ番号を重複登録しないよう制御する仕組みです（＝上限超過を防ぐ）。
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

# cpn_coupon_usage はクーポンの注文適用履歴を管理するテーブルです。適用額・返金額・利用状態や対象注文を記録し、
# 決済・返品・会計処理の整合を追跡します。
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

# cpn_coupon_user_history はユーザ保有クーポンの状態遷移ログを保持します。変更前後のステータスや操作種別、
# 関連注文・利用履歴を記録し、監査やトラブル調査に利用します。
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


# ord_order は EC 注文のヘッダ情報を管理するテーブルです。金額内訳、状態、適用クーポンや支払・配送ステータスを一元的に保持し、
# 決済・出荷・アフターサービスの各フローの起点となります。
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


# ord_order_item は注文に含まれる商品明細を管理するテーブルです。SKU・数量・価格情報のスナップショットを保持し、
# 在庫引当・返品・売上分析などの粒度として活用します。
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


# ord_payment は注文に紐づく決済トランザクションを管理するテーブルです。決済手段・プロバイダ・取引状態や各種時刻を
# 記録し、オーソリ〜キャプチャ〜返金までのライフサイクルを追跡します。
# ord_shipment は注文に対する配送情報を管理するテーブルです。配送業者・追跡番号・出荷/配達時刻や配送先スナップショットを
# 保持し、出荷進捗や問い合わせ対応に利用します。

