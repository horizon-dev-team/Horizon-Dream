// [HORIZON-EDIT] ADMIN-TICKETS
import { useState } from 'react';
import {
  Box,
  Button,
  Input,
  Modal,
  NoticeBox,
  Stack,
  TextArea,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type AdminhelpData = {
  adminCount: number;
  urgentAhelpEnabled: BooleanLike;
  bannedFromUrgentAhelp: BooleanLike;
  urgentAhelpPromptMessage: string;
};

type Recipient = 'admin' | 'mentor';

const RecipientTitles: Record<Recipient, string> = {
  admin: 'Create Adminhelp',
  mentor: 'Create Mentorhelp',
};

const RecipientPlaceholders: Record<Recipient, string> = {
  admin: 'Describe the problem concisely. Include names if reporting someone.',
  mentor: 'What do you need help with?',
};

const RecipientBorders: Record<Recipient, string> = {
  admin: '1px solid hsl(0, 50%, 30%)',
  mentor: '1px solid hsl(215, 50%, 40%)',
};

export const Adminhelp = (props) => {
  const { act, data } = useBackend<AdminhelpData>();
  const {
    adminCount,
    urgentAhelpEnabled,
    bannedFromUrgentAhelp,
    urgentAhelpPromptMessage,
  } = data;
  const [requestForAdmin, setRequestForAdmin] = useState(false);
  const [currentlyInputting, setCurrentlyInputting] = useState(false);
  const [ahelpMessage, setAhelpMessage] = useState('');
  const [recipient, setRecipient] = useState<Recipient | null>(null);

  const confirmationText = 'alert admins';
  const activeRecipient: Recipient = recipient ?? 'admin';
  const otherRecipient: Recipient =
    activeRecipient === 'admin' ? 'mentor' : 'admin';

  return (
    <Window
      title={RecipientTitles[activeRecipient]}
      theme="horizon"
      height={300}
      width={500}
      buttons={
        recipient && (
          <Button
            icon="exchange-alt"
            tooltip={`Switch ${otherRecipient}`}
            style={{ border: RecipientBorders[otherRecipient] }}
            onClick={() => setRecipient(otherRecipient)}
          >
            Switch Ticket
          </Button>
        )
      }
    >
      <Window.Content
        style={{
          backgroundImage: 'none',
        }}
      >
        {!recipient && <RecipientSelectionModal onSelect={setRecipient} />}
        <Stack vertical fill>
          <Stack.Item grow>
            <TextArea
              autoFocus
              backgroundColor="black"
              height="100%"
              fluid
              placeholder={RecipientPlaceholders[activeRecipient]}
              onChange={setAhelpMessage}
              style={{ border: RecipientBorders[activeRecipient] }}
            />
          </Stack.Item>
          {recipient === 'admin' && urgentAhelpEnabled && adminCount <= 0 && (
            <Stack.Item>
              <NoticeBox info>
                {urgentAhelpPromptMessage}
                {currentlyInputting ? (
                  <Box
                    mt={1}
                    width="100%"
                    fontFamily="arial"
                    backgroundColor="grey"
                    style={{
                      fontStyle: 'normal',
                    }}
                  >
                    Input &apos;{confirmationText}&apos; to proceed.
                    <Input
                      placeholder="Confirmation Prompt"
                      autoFocus
                      fluid
                      onChange={(value) => {
                        if (value === confirmationText) {
                          setRequestForAdmin(true);
                          setCurrentlyInputting(false);
                        }
                      }}
                    />
                  </Box>
                ) : (
                  <Button
                    mt={1}
                    onClick={() => {
                      if (requestForAdmin) {
                        setRequestForAdmin(false);
                      } else {
                        setCurrentlyInputting(true);
                      }
                    }}
                    color={requestForAdmin ? 'orange' : 'blue'}
                    icon={requestForAdmin ? 'check-square-o' : 'square-o'}
                    disabled={bannedFromUrgentAhelp}
                    tooltip={
                      bannedFromUrgentAhelp
                        ? 'You are banned from using urgent ahelps.'
                        : undefined
                    }
                    fluid
                    textAlign="center"
                  >
                    Alert admins?
                  </Button>
                )}
              </NoticeBox>
            </Stack.Item>
          )}
          <Stack.Item>
            <Button
              color="good"
              fluid
              textAlign="center"
              disabled={!ahelpMessage || !recipient}
              onClick={() =>
                act('ahelp', {
                  urgent: requestForAdmin,
                  message: ahelpMessage,
                  recipient: activeRecipient,
                })
              }
            >
              Submit
            </Button>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const RecipientSelectionModal = (props: {
  onSelect: (recipient: Recipient) => void;
}) => {
  const { onSelect } = props;

  return (
    <Modal>
      <Stack vertical width={32} textAlign="center">
        <Stack.Item>
          <Box bold color="label" fontSize="1.2em">
            Who do you need help from?
          </Box>
        </Stack.Item>
        <Stack.Item color="label">
          Admins handle rule violations and other out-of-character problems.
        </Stack.Item>
        <Stack.Item color="label">
          Mentors answer questions about game mechanics and the round.
        </Stack.Item>
        <Stack.Item>
          <Stack mt={1}>
            <Stack.Item grow>
              <Button
                fluid
                icon="gavel"
                color="bad"
                style={{ border: RecipientBorders.admin }}
                onClick={() => onSelect('admin')}
              >
                Admin Help
              </Button>
            </Stack.Item>
            <Stack.Item grow>
              <Button
                fluid
                icon="user-graduate"
                style={{ border: RecipientBorders.mentor }}
                onClick={() => onSelect('mentor')}
              >
                Mentor Help
              </Button>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Modal>
  );
};
