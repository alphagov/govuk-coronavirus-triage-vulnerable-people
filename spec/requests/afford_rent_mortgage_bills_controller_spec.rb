RSpec.describe "afford-rent-mortgage-bills" do
  let(:options) { I18n.t("coronavirus_form.groups.paying_bills.questions.afford_rent_mortgage_bills.options") }
  let(:selected_option) { options.keys.sample }
  let(:selected_option_text) { I18n.t("coronavirus_form.groups.paying_bills.questions.afford_rent_mortgage_bills.options.#{selected_option}.label") }

  before do
    allow_any_instance_of(QuestionsHelper).to receive(:questions_to_ask).and_return(%w(afford_rent_mortgage_bills feel_safe))
  end

  describe "GET /afford-rent-mortgage-bills" do
    context "without any questions to ask in the session data" do
      before do
        allow_any_instance_of(QuestionsHelper).to receive(:questions_to_ask).and_return(nil)
      end

      it "redirects to filter question" do
        get afford_rent_mortgage_bills_path

        expect(response).to redirect_to(controller: "need_help_with", action: "show")
      end
    end

    context "without session data" do
      it "shows the form" do
        visit afford_rent_mortgage_bills_path

        expect(page.body).to have_content(I18n.t("coronavirus_form.groups.paying_bills.questions.afford_rent_mortgage_bills.title"))
        I18n.t("coronavirus_form.groups.paying_bills.questions.afford_rent_mortgage_bills.options").each do |_, option|
          expect(page.body).to have_content(option[:label])
        end
      end
    end

    context "with session data" do
      before do
        page.set_rack_session(afford_rent_mortgage_bills: selected_option_text)
      end

      it "shows the form without prefilled response" do
        visit afford_rent_mortgage_bills_path

        expect(page.body).to have_content(I18n.t("coronavirus_form.groups.paying_bills.questions.afford_rent_mortgage_bills.title"))
        expect(page.find("input##{selected_option}")).not_to be_checked
      end
    end

    context "without this question in the sesion data" do
      before do
        allow_any_instance_of(QuestionsHelper).to receive(:questions_to_ask).and_return(%w(foo))
      end

      it "redirects to session expired" do
        get afford_rent_mortgage_bills_path

        expect(response).to redirect_to session_expired_path
      end
    end
  end

  describe "POST /afford-rent-mortgage-bills" do
    it "updates the session store" do
      post afford_rent_mortgage_bills_path, params: { afford_rent_mortgage_bills: selected_option_text }

      expect(session[:afford_rent_mortgage_bills]).to eq(selected_option_text)
    end

    it "redirects to the next question" do
      post afford_rent_mortgage_bills_path, params: { afford_rent_mortgage_bills: selected_option_text }

      expect(response).to redirect_to(controller: "feel_safe", action: "show")
    end

    it "shows an error when no radio button selected" do
      post afford_rent_mortgage_bills_path

      expect(response.body).to have_content(I18n.t("coronavirus_form.groups.paying_bills.questions.afford_rent_mortgage_bills.title"))
      expect(response.body).to have_content(I18n.t("coronavirus_form.groups.paying_bills.questions.afford_rent_mortgage_bills.custom_select_error"))
    end
  end
end
