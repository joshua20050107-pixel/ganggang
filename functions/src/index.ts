import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";

initializeApp();

export const onSaleCreated = onDocumentCreated(
  "teams/{teamId}/sales/{saleId}",
  async (event) => {
    const teamId = event.params.teamId;

    // 通知文言（簡潔に）
    const message = "おちんちん（売り上げ）が入りました";

    // トークン一覧を取得
    const tokensSnap = await getFirestore()
      .collection("teams")
      .doc(teamId)
      .collection("tokens")
      .get();

    const tokens = tokensSnap.docs.map((d) => d.id);
    if (tokens.length === 0) return;

    // 通知送信
    await getMessaging().sendEachForMulticast({
      tokens,
      notification: {
        title: "売上通知",
        body: message,
      },
    });

    console.log("通知送信:", message);
  }
);
