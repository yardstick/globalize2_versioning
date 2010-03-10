# This is the fully realized schema including translation/versioning tables
ActiveRecord::Schema.define do
  create_table :blogs, :force => true do |t|
    t.string      :description
  end

  create_table :posts, :force => true do |t|
    t.references  :blog
  end

  create_table :post_translations, :force => true do |t|
    t.string      :locale
    t.references  :post
    t.string      :subject
    t.text        :content
    t.datetime    :created_at
    t.datetime    :updated_at
  end

  create_table :sections, :force => true do |t|
  end

  create_table :section_translations, :force => true do |t|
    t.integer     :version
    t.string      :locale
    t.references  :section
    t.string      :title
    t.text        :content
    t.boolean     :current
    t.datetime    :created_at
    t.datetime    :updated_at
  end
  
  create_table :contents, :force => true do |t|
    t.string      :type
  end

  create_table :content_translations, :force => true do |t|
    t.integer     :version
    t.string      :locale
    t.references  :content
    t.string      :title
    t.text        :article
    t.boolean     :current
    t.datetime    :created_at
    t.datetime    :updated_at
  end  

  create_table :products, :force => true do |t|
  end

  create_table :product_translations, :force => true do |t|
    t.integer     :version
    t.string      :locale
    t.references  :product
    t.string      :title
    t.text        :content
    t.boolean     :current
    t.datetime    :created_at
    t.datetime    :updated_at
  end  

end
  
