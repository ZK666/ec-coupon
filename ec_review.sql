# レビュー／Q&Aドメイン（簡易版）
#
#   - rev_review            : レビュー本体（味・ボリューム・コスパの三軸評価）
#   - rev_tag_master        : 利用可能なレビュータグ
#   - rev_review_tag        : レビューとタグのひもづき
#   - rev_review_like       : 「参考になった」リアクション
#   - rev_review_photo      : レビュー写真
#   - rev_review_reply      : レビューへの返信
#   - rev_review_report     : レビュー通報
#   - rev_review_summary    : 商品単位のレビュー集計
#   - qa_question           : 商品Q&Aの質問
#   - qa_answer             : 商品Q&Aの回答
#   - qa_question_report    : Q&A通報

# rev_review は喫食者が投稿するレビューを管理します。
# 味・ボリューム・コスパの三軸評価とテキストコメントを保持し、店舗や SKU/SPU 単位で集計しやすい粒度を確保します。
CREATE TABLE rev_review
(
    id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT 'レビューID',
    review_code     VARCHAR(64)  NOT NULL DEFAULT '' COMMENT 'レビュー公開用コード',
    order_id        BIGINT UNSIGNED DEFAULT NULL COMMENT '関連注文ID',
    order_item_id   BIGINT UNSIGNED DEFAULT NULL COMMENT '関連注文明細ID',
    user_id         BIGINT UNSIGNED NOT NULL COMMENT '投稿ユーザID',
    vendor_id       BIGINT UNSIGNED NOT NULL COMMENT '店舗ID',
    sku_id          BIGINT UNSIGNED NOT NULL COMMENT '対象SKU ID',
    spu_id          BIGINT UNSIGNED DEFAULT NULL COMMENT '対象SPU ID',
    rating_taste    DECIMAL(2,1) NOT NULL COMMENT '味の評価(0.5刻み1.0-5.0)',
    rating_volume   DECIMAL(2,1) NOT NULL COMMENT 'ボリュームの評価(0.5刻み1.0-5.0)',
    rating_cost     DECIMAL(2,1) NOT NULL COMMENT 'コスパの評価(0.5刻み1.0-5.0)',
    comment         VARCHAR(512) NOT NULL DEFAULT '' COMMENT 'レビュー本文',
    is_anonymous    BOOLEAN      NOT NULL DEFAULT FALSE COMMENT '匿名表示フラグ',
    status          VARCHAR(32)  NOT NULL DEFAULT 'APPROVED' COMMENT '状態(/APPROVED/REJECTED)',
    visibility      VARCHAR(32)  NOT NULL DEFAULT 'PUBLIC' COMMENT '公開範囲(PUBLIC/PRIVATE)',
    helpful_count   INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '参考になった数',
    reviewed_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '投稿日時',
    is_deleted         BOOLEAN      NOT NULL DEFAULT FALSE COMMENT '削除フラグ（論理削除）',
    created_by         VARCHAR(128) NOT NULL DEFAULT '' COMMENT '作成者ユーザ名',
    updated_by         VARCHAR(128) NOT NULL DEFAULT '' COMMENT '更新者ユーザ名',
    created_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登録日時',
    updated_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    UNIQUE KEY uq_rev_review_code (review_code),
    KEY idx_rev_review_sku (sku_id, status, visibility)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT = 'レビュー本体';

# rev_tag_master はレビュー投稿時に選択できるタグのマスタです。
CREATE TABLE rev_tag_master
(
    id          BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT 'タグID',
    tag_code    VARCHAR(64)  NOT NULL DEFAULT '' COMMENT 'タグコード',
    tag_name    VARCHAR(64)  NOT NULL DEFAULT '' COMMENT 'タグ表示名',
    is_active   BOOLEAN      NOT NULL DEFAULT TRUE COMMENT '利用可否',
    sort_order  INT          NOT NULL DEFAULT 0 COMMENT '表示順',
    is_deleted         BOOLEAN      NOT NULL DEFAULT FALSE COMMENT '削除フラグ（論理削除）',
    created_by         VARCHAR(128) NOT NULL DEFAULT '' COMMENT '作成者ユーザ名',
    updated_by         VARCHAR(128) NOT NULL DEFAULT '' COMMENT '更新者ユーザ名',
    created_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登録日時',
    updated_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    UNIQUE KEY uq_rev_tag_code (tag_code)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT = 'レビュータグマスタ';

# rev_review_tag はレビューとタグの関連を保持します。
CREATE TABLE rev_review_tag
(
    id         BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT 'レビュータグID',
    review_id  BIGINT UNSIGNED NOT NULL COMMENT 'レビューID',
    tag_id     BIGINT UNSIGNED NOT NULL COMMENT 'タグID',
    is_deleted         BOOLEAN      NOT NULL DEFAULT FALSE COMMENT '削除フラグ（論理削除）',
    created_by         VARCHAR(128) NOT NULL DEFAULT '' COMMENT '作成者ユーザ名',
    updated_by         VARCHAR(128) NOT NULL DEFAULT '' COMMENT '更新者ユーザ名',
    created_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登録日時',
    updated_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    UNIQUE KEY uq_rev_review_tag (review_id, tag_id),
    KEY idx_rev_review_tag_review (review_id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT = 'レビュー×タグ関連';

# rev_review_like はレビューへの「参考になった」リアクションを保持します。
CREATE TABLE rev_review_like
(
    id         BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT 'レビューリアクションID',
    review_id  BIGINT UNSIGNED NOT NULL COMMENT '対象レビューID',
    user_id    BIGINT UNSIGNED NOT NULL COMMENT 'リアクションしたユーザID',
    is_deleted         BOOLEAN      NOT NULL DEFAULT FALSE COMMENT '削除フラグ（論理削除）',
    created_by         VARCHAR(128) NOT NULL DEFAULT '' COMMENT '作成者ユーザ名',
    updated_by         VARCHAR(128) NOT NULL DEFAULT '' COMMENT '更新者ユーザ名',
    created_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登録日時',
    updated_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    UNIQUE KEY uq_rev_review_like (review_id, user_id),
    KEY idx_rev_review_like_review (review_id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT = 'レビューリアクション';

# rev_review_photo はレビューに添付された写真情報を保持します。
CREATE TABLE rev_review_photo
(
    id         BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT 'レビュー写真ID',
    review_id  BIGINT UNSIGNED NOT NULL COMMENT 'レビューID',
    image_url  VARCHAR(512) NOT NULL COMMENT '画像URL',
    sort_order INT          NOT NULL DEFAULT 0 COMMENT '表示順',
    is_deleted         BOOLEAN      NOT NULL DEFAULT FALSE COMMENT '削除フラグ（論理削除）',
    created_by         VARCHAR(128) NOT NULL DEFAULT '' COMMENT '作成者ユーザ名',
    updated_by         VARCHAR(128) NOT NULL DEFAULT '' COMMENT '更新者ユーザ名',
    created_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登録日時',
    updated_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    KEY idx_rev_review_photo_review (review_id, sort_order)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT = 'レビュー添付写真';

# rev_review_reply は店舗や運営からの返信を保持します。
CREATE TABLE rev_review_reply
(
    id           BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT 'レビュー返信ID',
    review_id    BIGINT UNSIGNED NOT NULL COMMENT '対象レビューID',
    reply_user_id BIGINT UNSIGNED DEFAULT NULL COMMENT '返信したユーザID',
    reply_role   VARCHAR(32)  NOT NULL DEFAULT 'VENDOR' COMMENT '返信者種別(VENDOR/ADMIN)',
    body         TEXT         NOT NULL COMMENT '返信本文',
    is_deleted         BOOLEAN      NOT NULL DEFAULT FALSE COMMENT '削除フラグ（論理削除）',
    created_by         VARCHAR(128) NOT NULL DEFAULT '' COMMENT '作成者ユーザ名',
    updated_by         VARCHAR(128) NOT NULL DEFAULT '' COMMENT '更新者ユーザ名',
    created_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登録日時',
    updated_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    KEY idx_rev_review_reply_review (review_id, created_at)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT = 'レビューへの返信';

# rev_review_report は不適切レビューの通報を保持します。
CREATE TABLE rev_review_report
(
    id         BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT 'レビュー通報ID',
    review_id  BIGINT UNSIGNED NOT NULL COMMENT '対象レビューID',
    reporter_id BIGINT UNSIGNED NOT NULL COMMENT '通報ユーザID',
    reason     VARCHAR(255) NOT NULL DEFAULT '' COMMENT '通報理由',
    status     VARCHAR(32)  NOT NULL DEFAULT 'RECEIVED' COMMENT '対応状況',
    is_deleted         BOOLEAN      NOT NULL DEFAULT FALSE COMMENT '削除フラグ（論理削除）',
    created_by         VARCHAR(128) NOT NULL DEFAULT '' COMMENT '作成者ユーザ名',
    updated_by         VARCHAR(128) NOT NULL DEFAULT '' COMMENT '更新者ユーザ名',
    created_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登録日時',
    updated_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    KEY idx_rev_review_report_review (review_id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT = 'レビュー通報';

# rev_review_summary は商品ごとのレビュー集計を保持します。
# 味・ボリューム・コスパの平均値を計算しておき、商品詳細で即時表示します。
CREATE TABLE rev_review_summary
(
    id               BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT 'レビューサマリID',
    sku_id           BIGINT UNSIGNED NOT NULL COMMENT '対象SKU ID',
    spu_id           BIGINT UNSIGNED DEFAULT NULL COMMENT '対象SPU ID',
    vendor_id        BIGINT UNSIGNED NOT NULL COMMENT '店舗ID',
    corp_id          BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '企業ID(0は全体用)',
    review_count     INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'レビュー件数',
    avg_rating_taste DECIMAL(4,2) NOT NULL DEFAULT 0.00 COMMENT '味の平均評価',
    avg_rating_volume DECIMAL(4,2) NOT NULL DEFAULT 0.00 COMMENT 'ボリュームの平均評価',
    avg_rating_cost  DECIMAL(4,2) NOT NULL DEFAULT 0.00 COMMENT 'コスパの平均評価',
    helpful_total    INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '参考になった合計',
    photo_count      INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '写真付きレビュー件数',
    is_deleted         BOOLEAN      NOT NULL DEFAULT FALSE COMMENT '削除フラグ（論理削除）',
    created_by         VARCHAR(128) NOT NULL DEFAULT '' COMMENT '作成者ユーザ名',
    updated_by         VARCHAR(128) NOT NULL DEFAULT '' COMMENT '更新者ユーザ名',
    created_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登録日時',
    updated_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    UNIQUE KEY uq_rev_review_summary (sku_id, vendor_id, corp_id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT = 'SKU別レビュー集計';

# qa_question は商品に関する質問を保持します。
CREATE TABLE qa_question
(
    id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT '質問ID',
    question_code VARCHAR(64)  NOT NULL DEFAULT '' COMMENT '公開用コード',
    user_id       BIGINT UNSIGNED NOT NULL COMMENT '質問者ユーザID',
    corp_id       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '所属企業ID',
    vendor_id     BIGINT UNSIGNED NOT NULL COMMENT '店舗ID',
    sku_id        BIGINT UNSIGNED NOT NULL COMMENT '対象SKU ID',
    spu_id        BIGINT UNSIGNED DEFAULT NULL COMMENT '対象SPU ID',
    title         VARCHAR(160) NOT NULL DEFAULT '' COMMENT '質問タイトル',
    body          TEXT         NOT NULL COMMENT '質問本文',
    status        VARCHAR(32)  NOT NULL DEFAULT 'PENDING' COMMENT '状態(PENDING/PUBLISHED/CLOSED)',
    is_deleted         BOOLEAN      NOT NULL DEFAULT FALSE COMMENT '削除フラグ（論理削除）',
    created_by         VARCHAR(128) NOT NULL DEFAULT '' COMMENT '作成者ユーザ名',
    updated_by         VARCHAR(128) NOT NULL DEFAULT '' COMMENT '更新者ユーザ名',
    created_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登録日時',
    updated_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    UNIQUE KEY uq_qa_question_code (question_code),
    KEY idx_qa_question_sku (sku_id, status)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT = '商品Q&A質問';

# qa_answer は QA 質問への回答を保持します。
CREATE TABLE qa_answer
(
    id           BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT '回答ID',
    question_id  BIGINT UNSIGNED NOT NULL COMMENT '対象質問ID',
    responder_id BIGINT UNSIGNED DEFAULT NULL COMMENT '回答者ユーザID',
    responder_role VARCHAR(32) NOT NULL DEFAULT 'VENDOR' COMMENT '回答者種別(VENDOR/ADMIN)',
    body         TEXT         NOT NULL COMMENT '回答本文',
    status       VARCHAR(32)  NOT NULL DEFAULT 'PUBLISHED' COMMENT '状態(PENDING/PUBLISHED/HIDDEN)',
    is_deleted         BOOLEAN      NOT NULL DEFAULT FALSE COMMENT '削除フラグ（論理削除）',
    created_by         VARCHAR(128) NOT NULL DEFAULT '' COMMENT '作成者ユーザ名',
    updated_by         VARCHAR(128) NOT NULL DEFAULT '' COMMENT '更新者ユーザ名',
    created_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登録日時',
    updated_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    KEY idx_qa_answer_question (question_id, status, created_at)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT = '商品Q&A回答';

# qa_question_report は質問や回答への通報を保持します。
CREATE TABLE qa_question_report
(
    id          BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT 'Q&A通報ID',
    question_id BIGINT UNSIGNED NOT NULL COMMENT '対象質問ID',
    answer_id   BIGINT UNSIGNED DEFAULT NULL COMMENT '対象回答ID',
    reporter_id BIGINT UNSIGNED NOT NULL COMMENT '通報ユーザID',
    reason      VARCHAR(255) NOT NULL DEFAULT '' COMMENT '通報理由',
    status      VARCHAR(32)  NOT NULL DEFAULT 'RECEIVED' COMMENT '対応状況',
    is_deleted         BOOLEAN      NOT NULL DEFAULT FALSE COMMENT '削除フラグ（論理削除）',
    created_by         VARCHAR(128) NOT NULL DEFAULT '' COMMENT '作成者ユーザ名',
    updated_by         VARCHAR(128) NOT NULL DEFAULT '' COMMENT '更新者ユーザ名',
    created_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登録日時',
    updated_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
    KEY idx_qa_question_report_question (question_id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT = 'Q&A通報';
