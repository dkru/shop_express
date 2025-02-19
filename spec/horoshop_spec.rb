# frozen_string_literal: true

require 'spec_helper'

describe Horoshop::Client do
  subject { described_class.new(params) }

  let(:url) { 'http://api.horosop.com' }
  let(:login) { 'user213' }
  let(:password) { 'pass' }
  let(:params) do
    { url: url, login: login, password: password }
  end

  describe '#token_valid?' do
    context 'when token is present and not expired' do
      before do
        subject.token = '2sgv458'
        subject.expiration_timestamp = Time.now - 400
      end

      it 'returns true' do
        expect(subject.token_valid?).to be true
      end
    end

    context 'when token is present but expired' do
      before do
        subject.token = '2sgv458'
        subject.expiration_timestamp = Time.now + 700
      end

      it 'returns false' do
        expect(subject.token_valid?).to be false
      end
    end

    context 'when token is nil' do
      before do
        subject.token = nil
      end

      it 'returns false' do
        expect(subject.token_valid?).to be false
      end
    end
  end

  describe '#refresh_token!' do
    let(:auth) { instance_double(Horoshop::Authorization) }

    before do
      allow(Horoshop::Authorization).to receive(:new).with(subject).and_return(auth)
      allow(auth).to receive(:authorize)
    end

    it 'calls authorize on a new Horoshop::Authorization instance' do
      subject.refresh_token!
      expect(Horoshop::Authorization).to have_received(:new).with(subject)
      expect(auth).to have_received(:authorize)
    end

    context 'when authorize updates the token and expiration_timestamp' do
      let(:new_token) { '123w45' }
      let(:new_expiration_timestamp) { Time.now }

      before do
        allow(auth).to receive(:authorize) do
          subject.token = new_token
          subject.expiration_timestamp = new_expiration_timestamp
        end
      end

      it 'updates the token and expiration_timestamp on the Horoshop instance' do
        expect { subject.refresh_token! }.to change(subject, :token).from(nil)
                                                                    .to(new_token)
                                                                    .and change(subject, :expiration_timestamp)
          .from(nil).to(new_expiration_timestamp)
      end
    end
  end
end
