require_relative "../spec_helper"

RSpec.describe Metabox::ApiClient do
  
    def _get_instance
      Metabox::MetaboxDocument.new
    end
    
    def _get_empty_document
        {
            "Metabox" => {
               
            }
        }.to_yaml
    end

    def _get_empty_document_with_description
        {
            "Metabox" => {
                "Description" => "A valid metabox document"
            }
        }.to_yaml
    end

    def _get_minimal_document
        {
            "Metabox" => {
                "Description" => "A minimal metabox document",

                "Resources" => {
                    "centos7-mb-canary" => {
                        "Type" => "metabox::packer::build"
                    },
                    "centos7-mb-canary-1" => {
                        "Type" => "metabox::packer::build"
                    },
                    "vagrant-env" => {
                        "Type" => "vagrant::stack",

                        "Resources" => {
                            "win2008" => {

                            },
                            "win2012" => {

                            },
                        }
                    }
                }
            }
        }.to_yaml
    end

    context '.initialise' do
      it 'Can create instance' do
        client = _get_instance
    
        expect(client).not_to be nil
      end
    end

    context '.parse' do
        
        it 'raise on invalid document' do
          document = _get_instance
          document_data = {}.to_yaml
      
          expect {
            document.parse(document_data) 
          }.to raise_error(/Cannot find section/)
        end

        it 'parse valid document' do
            document = _get_instance
            document_data = _get_empty_document
        
            result = document.parse(document_data) 

            expect(result).not_to be nil
            expect(document.description).to eq('')
        end

        it 'parse valid document with description' do
            document = _get_instance
            document_data = _get_empty_document_with_description
        
            result = document.parse(document_data) 

            expect(result).not_to be nil
            expect(document.description).to eq("A valid metabox document")
        end

        it 'parse resources - empty' do
            document = _get_instance
            document_data = _get_empty_document
        
            result = document.parse(document_data) 

            expect(result).not_to be nil
            expect(document.description).to eq('')

            expect(document.all_resources.count).to eq(0)
            expect(document.packer_build_resources.count).to eq(0)
            expect(document.vagrant_environment_resources.count).to eq(0)
        end

        it 'parse resources - vagrant/packer' do
            document = _get_instance
            document_data = _get_minimal_document

            result = document.parse(document_data) 

            expect(result).not_to be nil
            expect(document.description).to eq("A minimal metabox document")

            expect(document.all_resources.count).to eq(3)
            expect(document.packer_build_resources.count).to eq(2)
            expect(document.vagrant_environment_resources.count).to eq(1)

            expect(document.vagrant_vm_resources.count).to eq(2)

            puts document
        end

        it 'to_s' do
            document = _get_instance
            document_data = _get_minimal_document

            result = document.parse(document_data) 

            expect(result).not_to be nil
            expect(document.description).to eq("A minimal metabox document")

            expect(document.all_resources.count).to eq(3)
            expect(document.packer_build_resources.count).to eq(2)
            expect(document.vagrant_environment_resources.count).to eq(1)

            expect(document.vagrant_vm_resources.count).to eq(2)

            string_value =  "#{document}"

            expect(string_value.include? "Description: A minimal metabox document" ).to eq(true)
        end
        
      end

  end
  