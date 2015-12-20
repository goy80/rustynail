# coding: utf-8


# ファセットオプションカラムの日本語名
column_name_converter = {
  price_zone: "価格",
  maker: "メーカー"
}

# ファセットオプション選択肢日本語名
option_name_converter = {
  price_zone: {
    "0" => "5,000円未満",
    "5000" => "5,000～10,000円",
    "10000" => "10,000～30,000円",
    "30000" => "30,000～50,000円",
    "50000" => "50,000円以上"
  }

}

# ソートオプション日本語名
sort_option_converter = {
  updated_at: {
    asc: "古い順",
    desc: "更新順"
  },
  sales_rank: {
    asc: "人気順"
  },
  price: {
    asc: "安い順",
    desc: "高い順"
  }
}



Rustynail.configure do | config |
  config.column_name_converter = column_name_converter
  config.option_name_converter = option_name_converter
  config.sort_option_converter = sort_option_converter
  config.facet_max = 100
end
