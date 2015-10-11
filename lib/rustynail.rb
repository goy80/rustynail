require "rustynail/version"

module Rustynail

  @facet_columns = []
  @keyword_target_columns = []
  @table_name = "table"

  def self.facet_options opt={}

    opt = {} if opt.nil?
    filter = {}
    opt.each do | key, value |
      filter[ key.to_sym ] = value
    end

    # filterオプションの構築
    filter_conds = []
    @facet_columns.each do | column |
      if filter.key? key
        filter_conds << "#{ column } == #{ filter[ column ] }"
      end
    end
    filter_option = filter_conds.length > 0 ? %!--filter '#{ filter_conds.join(" && ") }'! : ""

    #
    # --match_columns 全文検索対象カラム
    # --filter 絞込み条件
    #
    sql = %!SELECT mroonga_command("select #{ @table_name } \
            --limit 0 \
            --match_columns '#{ @keyword_target_columns.join("||") }' \
            --query '#{ filter[ :keyword ] }' #{filter_option} \
            --drilldown '#{ @facet_columns.join(",") }' \
            --drilldown_sortby '-_nsubrecs, _key' \
            --drilldown_limit -1 \
            ") AS facet_options !



    dum = connection.select sql
    res = JSON.parse( dum.first["facet_options"] )
    res.delete_at( 0 )

    ret = {}

    @facet_columns.each_with_index do | column, idx |
      2.times do
        res[ idx ].delete_at 0
      end
      ret[ column ] = Hash[ *res[ idx ].flatten ]
    end
    ret

  end


end
