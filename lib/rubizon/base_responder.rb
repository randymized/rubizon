class BaseResponder
  def process(status_and_body)
    unless status_and_body.status == 200
      #Raise an exception!  Some kind of error has occurred.
      debugger
      parsed= XmlSimple.xml_in(status_and_body.body,:ForceArray=>true)
      info= parsed['Errors'].first['Error'].first
      errname= 'AWS'+info['Code'].first+'Error'
      errclass= status_and_body.status/100 == '5' ? Class.new(Rubizon::AWSServerError) : Class.new(Rubizon::AWSClientError)
      Rubizon.const_set(errname,errclass) unless Rubizon.const_defined?(errname)
      raise Rubizon.const_get(errname).new(info['Message'].first)
    end
    parsed
  end
end

