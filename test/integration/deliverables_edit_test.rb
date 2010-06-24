require 'test_helper'

class DeliverablesEditTest < ActionController::IntegrationTest
  include Redmine::I18n
  
  def setup
    @project = Project.generate!(:identifier => 'main')
    @contract = Contract.generate!(:project => @project, :name => 'A Contract', :payment_terms => 'net_15')
    @manager = User.generate!
    @deliverable = FixedDeliverable.generate!(:contract => @contract, :manager => @manager, :title => 'The Title')
  end

  should "allow any user to edit the deliverable" do
    visit_contract_page(@contract)
    click_link_within "#fixed_deliverable_#{@deliverable.id}", 'Edit'
    assert_response :success
    assert_template 'deliverables/edit'

    assert_select "form#edit_fixed_deliverable_#{@deliverable.id}" do
      assert_select "input#fixed_deliverable_title[value=?]", /#{@deliverable.title}/
      assert_select "select#fixed_deliverable_type" do
        assert_select "option[selected=selected][value=FixedDeliverable]"
      end
    end

    fill_in "Title", :with => 'An updated title'
    click_button "Save"

    assert_response :success
    assert_template 'contracts/show'

    assert_equal "An updated title", @deliverable.reload.title

  end
end
