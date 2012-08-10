#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'rexml/document'
require 'rexml/element'
require 'yaml'
require 'erb'

class MysqlTableMemo
  attr_accessor :doc

  HEADERS = %w(Field Type Null Key Default Extra)

  def initialize(host, user, password, database, table)
    xml = `echo 'DESC #{table};' | mysql --xml -h#{host} -u#{user} --password=#{password} #{database}`
    @doc = REXML::Document.new(xml)
    @table = table
    @headers = HEADERS
  end

  def memo=(memo)
    return nil unless memo

    @headers << 'Memo' unless @headers.include?('Memo')
    resultset = @doc.elements['/resultset']
    resultset.elements.each do |row|
      field = row.elements.find { |field| field.attributes['name'] == 'Field' }
      memo_field = REXML::Element.new 'field'
      memo_field.attributes['name'] = 'Memo'
      memo_field.text = memo[field.text]
      row.add_element memo_field
    end
  end

  def to_html
    erb = ERB.new(html_erb)
    table = @table
    headers = @headers
    resultset = @doc.elements['/resultset']

    return erb.result(binding)
  end

  private
  def html_erb
    <<-HTML
<TABLE>
  <CAPTION><%= table %></CAPTION>
  <TR>
    <% headers.each do |header| %><TH><%= header %></TH><% end %>
  </TR><% resultset.elements.each do |row| %><TR>
    <% headers.each do |header| %><TD><%=
      field = row.elements.find { |field| field.attributes['name'] == header if field.respond_to?('attributes') }
      case
      when field && field.text && field.text.length > 0
        field.text
      when field.respond_to?('attributes') && field.attributes['xsi:nil']
        'NULL' if field.attributes['xsi:nil'] == 'true'
      end %></TD><% end %>
  </TR><% end %>
</TABLE>
    HTML
  end
end


if __FILE__ == $0
  require 'optparse'

  # init
  memo = "#{Dir.pwd}/memo.yml"
  host = 'localhost'
  user = 'root'
  password = ''
  database = 'mydatabase'

  opt = OptionParser.new
  opt.on('-m VAL') { |v| memo = v }
  opt.on('-h VAL') { |v| host = v }
  opt.on('-u VAL') { |v| user = v }
  opt.on('-p')     { |v| print 'Password:'; password = gets.strip }
  opt.parse!(ARGV)

  tables = `echo 'SHOW TABLES;' | mysql -N -h#{host} -u#{user} --password=#{password} #{database}`.split("\n")

  yaml = YAML.load_file(memo)

  tables.each do |table|
    mysqlmemo = MysqlTableMemo.new(host, user, password, database, table)
    mysqlmemo.memo = yaml[table]
    print mysqlmemo.to_html
  end

  exit 0
end

