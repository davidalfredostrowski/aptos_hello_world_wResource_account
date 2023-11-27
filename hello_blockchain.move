module hello_blockchain::message {
    use std::error;
    use std::signer;
    use std::string;
    use aptos_framework::event;
    use aptos_framework::account::SignerCapability;
    use aptos_framework::resource_account;
    use aptos_framework::account;

    struct ModuleData has key {
        // Storing the signer capability here, so the module can programmatically sign for transactions
        signer_cap: SignerCapability
//        token_data_id: TokenDataId,
    }


    //:!:>resource
    struct MessageHolder has key {
        message: string::String,
    }
    //<:!:resource
    #[event]
    struct MessageChange has drop, store {
        account: address,
        from_message: string::String,
        to_message: string::String,
    }

    /// There is no message present
    const ENO_MESSAGE: u64 = 0;
 fun init_module(resource_signer: &signer) {
        // Retrieve the resource signer's signer capability and store it within the `ModuleData`.
        // Note that by calling `resource_account::retrieve_resource_account_cap` to retrieve the resource account's signer capability,
        // we rotate th resource account's authentication key to 0 and give up our control over the resource account. Before calling this function,
        // the resource account has the same authentication key as the source account so we had control over the resource account.
        let resource_signer_cap = resource_account::retrieve_resource_account_cap(resource_signer, @source_addr);

        // Store the token data id and the resource account's signer capability within the module, so we can programmatically
        // sign for transactions in the `mint_event_ticket()` function.
        move_to(resource_signer, ModuleData {
            signer_cap: resource_signer_cap,
        });
    }

    #[view]
    public fun get_message(addr: address): string::String acquires MessageHolder {
        assert!(exists<MessageHolder>(addr), error::not_found(ENO_MESSAGE));
        borrow_global<MessageHolder>(addr).message
    }


    public entry fun set_message(account: signer, message: string::String)
   // acquires MessageHolder, ModuleData {
   acquires ModuleData {

        let module_data = borrow_global_mut<ModuleData>(@hello_blockchain);

//        let account_addr = signer::address_of(&account);
//###### change back to normal .....
let resource_signer = account::create_signer_with_capability(&module_data.signer_cap);

  //      let account_addr = resource_signer::address_of(&account);

//        if (!exists<MessageHolder>(account_addr)) {
            move_to(&resource_signer, MessageHolder {
                message,
            })
     }




 //   public entry fun set_message(account: signer, message: string::String)
 //   acquires MessageHolder {
 //       let account_addr = signer::address_of(&account);
 //       if (!exists<MessageHolder>(account_addr)) {
 //           move_to(&account, MessageHolder {
 //               message,



//   public entry fun set_message(account: signer, message: string::String)
 //   acquires MessageHolder {
 //       let account_addr = signer::address_of(&account);
 //       if (!exists<MessageHolder>(account_addr)) {
 //           move_to(&account, MessageHolder {
 //               message,
 //           })
 //       } else {
 //           let old_message_holder = borrow_global_mut<MessageHolder>(account_addr);
 //           let from_message = old_message_holder.message;
 //           event::emit(MessageChange {
 //               account: account_addr,
 //               from_message,
 //               to_message: copy message,
 //           });
 //           old_message_holder.message = message;
 //       }
 //   }

    #[test(account = @0x1)]
    public entry fun sender_can_set_message(account: signer) acquires MessageHolder {
        let addr = signer::address_of(&account);
        aptos_framework::account::create_account_for_test(addr);
        set_message(account, string::utf8(b"Hello, Blockchain"));

        assert!(
            get_message(addr) == string::utf8(b"Hello, Blockchain"),
            ENO_MESSAGE
        );
    }
}
     
