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
